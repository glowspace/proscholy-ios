//
//  DownloadService.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import CoreData

class DownloadService {
    
    private init() { }
    
    struct Query {
        let type: String
        var fields: [Any]
        var arguments: [String: String]?
        
        init(type: String, fields: [Any], arguments: [String: String]? = nil) {
            self.type = type
            self.fields = fields
            self.arguments = arguments
        }
        
        func generate() -> String {
            var generated = type
            if let arguments = arguments, arguments.count > 0 {
                generated += "("
                for (key, value) in arguments {
                    generated += String(format: "%@:\"%@\",", key, value)
                }
                generated += ")"
            }
            generated += "{"
            for field in fields {
                if let field = field as? String {
                    generated += String(format: "%@,", field)
                } else if let field = field as? Query {
                    generated += String(format: "%@,", field.generate())
                }
            }
            generated += "}"
            
            return generated
        }
    }
    
    static func updateSongs(_ updater: @escaping (String) -> Void, _ completionHandler: @escaping () -> Void) {
        if Reachability.networkIsReachableOverWifi() {
            downloadSongData(updater, completionHandler)
        } else {
            loadSongDataFromFile(completionHandler)
        }
    }
    
    // MARK: - Data Loading
    
    private static func downloadSongData(_ updater: @escaping (String) -> Void, _ completionHandler: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        var arguments = [String: String]()
        
        if let lastUpdate = defaults.string(forKey: "lastUpdate") {
            arguments["updated_after"] = lastUpdate
        }
        
        let queries = [
            Query(type: "song_lyrics", fields: ["id", "lyrics", "name", "lang_string", "type", "trashed",
                Query(type: "song", fields: ["id", "name"]),
                Query(type: "songbook_records", fields: ["id", "number",
                     Query(type: "songbook", fields: ["id"])]),
                Query(type: "authors", fields: ["id", "name"]),
                Query(type: "tags", fields: ["id"])], arguments: arguments),
            Query(type: "songbooks", fields: ["id", "name", "shortcut", "is_private", "color"]),
            Query(type: "tags", fields: ["id", "name",
                 Query(type: "parent_tag", fields: ["id"])])
        ]
        
        guard let encodedUrl = generateQuery("https://zpevnik.proscholy.cz", queries).addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else { return }
        
        updater("Aktualizace databáze písní.")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        
        URLSession(configuration: sessionConfig).dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                loadSongDataFromFile(completionHandler)
                return
            }
            
            guard let data = data else { return }
            
            do {
                updater("Příprava písní")
                
                try prepareData(data)
                
                setLastUpdate(defaults)
                
                completionHandler()
            } catch {
                loadSongDataFromFile(completionHandler)
            }
        }.resume()
    }
    
    private static func loadSongDataFromFile(_ completionHandler: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "defaultDataLoaded") || defaults.string(forKey: "lastUpdate") != nil {
            completionHandler()
            return
        }
        
        do {
            guard let path = Bundle.main.path(forResource: "data", ofType: "json") else { return }
            try prepareData(Data(contentsOf: URL(fileURLWithPath: path)))
            
            defaults.set(true, forKey: "defaultDataLoaded")
            
            completionHandler()
        } catch { }
    }
    
    private static func prepareData(_ data: Data) throws {
        guard let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
        
        let context = PersistenceService.persistentContainer.newBackgroundContext()
        
        guard let data = jsonData["data"] as? [String: Any] else { return }
        
        if let languages: [Language] = CoreDataService.fetchData(context: context) {
            for language in languages {
                language.count = 0
            }
        }
        
        createSongBooks(from: data["songbooks"] as? [[String: Any]], context)
        createTags(from: data["tags"] as? [[String: Any]], context)
        createSongLyrics(from: data["song_lyrics"] as? [[String: Any]], context)
        
        try context.save()
    }
    
    // MARK: - Objects Parsing
    
    private static func createSongBooks(from data: [[String: Any]]?, _ context: NSManagedObjectContext) {
        guard let data = data else { return }
        
        for songBookData in data {
            _ = SongBook.createFromDict(songBookData, context)
        }
    }
    
    private static func createTags(from data: [[String: Any]]?, _ context: NSManagedObjectContext) {
        guard let data = data else { return }
        
        removeOldTags(context)
        
        for tagsData in data {
            _ = Tag.createFromDict(tagsData, context)
        }
        
        for tagsData in data {
            if let id = tagsData["id"] as? String, let parentTag = tagsData["parent_tag"] as? [String: String], let parentId = parentTag["id"] {
                if let tag: Tag = CoreDataService.getObject(id: id, context: context), let parent: Tag = CoreDataService.getObject(id: parentId, context: context) {
                    tag.parent = parent
                    parent.addToChildren(tag)
                }
            }
        }
    }
    
    private static func removeOldTags(_ context: NSManagedObjectContext) {
        if let tags: [Tag] = CoreDataService.fetchData(context: context) {
            for tag in tags {
                context.delete(tag)
            }
        }
    }
    
    private static func createSongLyrics(from data: [[String: Any]]?, _ context: NSManagedObjectContext) {
        guard let data = data else { return }
        
        for songLyricsData in data {
            if let songLyric = SongLyric.createFromDict(songLyricsData, context) {
                createSong(songLyricsData["song"], forSongLyric: songLyric, context: context)
                
                createSongBookRecords(songLyricsData["songbook_records"], forSongLyric: songLyric, context: context)
                
                createAuthors(songLyricsData["authors"], forSongLyric: songLyric, context: context)
                
                if let tagsData = songLyricsData["tags"] as? [[String: String]] {
                    for tagData in tagsData {
                        if let id = tagData["id"], let tag: Tag = CoreDataService.getObject(id: id, context: context) {
                            tag.addToSongLyrics(songLyric)
                            songLyric.addToTags(tag)
                        }
                    }
                }
                
                if let lang = songLyricsData["lang_string"] as? String {
                    if let languages: [Language] = CoreDataService.fetchData(predicate: NSPredicate(format: "name == %@", lang), context: context), languages.count > 0 {
                        languages[0].count += 1
                    } else {
                        if let language = NSEntityDescription.insertNewObject(forEntityName: "Language", into: context) as? Language {
                            language.name = lang
                        }
                    }
                }
            }
        }
    }
    
    private static func createSong(_ data: Any?, forSongLyric songLyric: SongLyric, context: NSManagedObjectContext) {
        guard let data = data as? [String: Any] else { return }
        
        if let song = Song.createFromDict(data, context) {
            song.addToSongLyrics(songLyric)
            songLyric.song = song
        }
    }
    
    private static func createSongBookRecords(_ data: Any?, forSongLyric songLyric: SongLyric, context: NSManagedObjectContext) {
        guard let data = data as? [[String: Any]] else { return }
        
        var records = [SongBookRecord]()
        for songBookRecordData in data {
            if let songBookRecord = SongBookRecord.createFromDict(songBookRecordData, context) {
                records.append(songBookRecord)
                
                songBookRecord.songLyric = songLyric
                songLyric.addToSongBookRecords(songBookRecord)
            }
        }
        
        if let songBookRecords = songLyric.songBookRecords?.allObjects as? [SongBookRecord] {
            for songBookRecord in songBookRecords {
                if !records.contains(songBookRecord) {
                    songLyric.removeFromSongBookRecords(songBookRecord)
                    context.delete(songBookRecord)
                }
            }
        }
    }
    
    private static func createAuthors(_ data: Any?, forSongLyric songLyric: SongLyric, context: NSManagedObjectContext) {
        guard let data = data as? [[String: Any]] else { return }
        
        var authors = [Author]()
        for authorData in data {
            if let author = Author.createFromDict(authorData, context) {
                authors.append(author)
                
                author.addToSongLyrics(songLyric)
                songLyric.addToAuthors(author)
            }
        }
        
        if let songLyricAuthor = songLyric.authors?.allObjects as? [Author] {
            for author in songLyricAuthor {
                if !authors.contains(author) {
                    songLyric.removeFromAuthors(author)
                    context.delete(author)
                }
            }
        }
    }
    
    // MARK: - Help Functions
    
    private static func setLastUpdate(_ defaults: UserDefaults) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        defaults.set(formatter.string(from: Date()), forKey: "lastUpdate")
    }
    
    private static func generateQuery(_ baseUrl: String, _ queries: [Query]) -> String {
        var url = baseUrl + "/graphql?query={"
        
        for query in queries {
            url += query.generate()
        }
        
        url += "}"
        
        return url
    }
}
