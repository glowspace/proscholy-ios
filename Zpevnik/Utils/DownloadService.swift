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
        if !isUpdateNeeded() {
            completionHandler()
            return
        }
        
        if Reachability.networkIsReachableOverWifi() {
            do {
                try download(updater, completionHandler)
            } catch {
                loadSongDataFromFile(completionHandler)
            }
        } else {
            loadSongDataFromFile(completionHandler)
        }
    }
    
    // MARK: - Data Loading
    
    private static func download(_ updater: @escaping (String) -> Void, _ completionHandler: @escaping () -> Void) throws {
        let defaults = UserDefaults.standard
        var songLyricsArguments = [String: String]()
        if let lastUpdate = defaults.string(forKey: "lastUpdate") {
            songLyricsArguments["updated_after"] = lastUpdate
        }
        
        let queries = [
            Query(type: "song_lyrics", fields: ["id", "lyrics", "name", "lang_string", "type", "trashed",
                Query(type: "song", fields: ["id", "name"]),
                Query(type: "songbook_records", fields: ["id", "number",
                     Query(type: "songbook", fields: ["id"])]),
                Query(type: "authors", fields: ["id", "name"]),
                Query(type: "tags", fields: ["id"])], arguments: songLyricsArguments),
            Query(type: "songbooks", fields: ["id", "name", "shortcut", "is_private", "color"]),
            Query(type: "tags", fields: ["id", "name",
                 Query(type: "parent_tag", fields: ["id"])])
        ]
        
        var arguments: [String: String] = queries.reduce(into: [:]) { result, query in result["query", default: "{"] += query.generate() }
        arguments["query", default: "{"] += "}"
        
        guard let url = URL(string: "https://zpevnik.proscholy.cz/graphql") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONSerialization.data(withJSONObject: arguments)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        
        URLSession(configuration: sessionConfig).dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                loadSongDataFromFile(completionHandler)
                return
            }
            
            guard let data = data else { return }
            
            do {
                updater("Příprava písní")
                
                if try prepareData(data) {
                    setLastUpdate(defaults)
                    
                    completionHandler()
                } else {
                    loadSongDataFromFile(completionHandler)
                }
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
            _ = try prepareData(Data(contentsOf: URL(fileURLWithPath: path)))
            
            defaults.set(true, forKey: "defaultDataLoaded")
            
            completionHandler()
        } catch { }
    }
    
    private static func prepareData(_ data: Data) throws -> Bool {
        guard let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return false }
        
        let context = PersistenceService.backgroundContext
        
        guard let data = jsonData["data"] as? [String: [[String: Any]]] else { return false }
        
        createSongBooks(from: data["songbooks"], context)
        createTags(from: data["tags"], context)
        createSongLyrics(from: data["song_lyrics"], context)
        
        PersistenceService.saveContext()
        
        return true
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
        
        disableOldTags(context)
        
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
    
    private static func disableOldTags(_ context: NSManagedObjectContext) {
        if let tags: [Tag] = CoreDataService.fetchData(context: context) {
            for tag in tags {
                tag.isValid = false
            }
        }
    }
    
    private static func createSongLyrics(from data: [[String: Any]]?, _ context: NSManagedObjectContext) {
        guard let data = data else { return }
        
        for songLyricsData in data {
            let existed: Bool
            
            if let id = songLyricsData["id"] as? String, let _: SongLyric = CoreDataService.getObject(id: id, context: context) {
                existed = true
            } else {
                existed = false
            }
            
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
                
                if !existed, let lang = songLyricsData["lang_string"] as? String {
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
    
    private static func isUpdateNeeded() -> Bool {
        let defaults = UserDefaults.standard
        
        if let lastUpdate = defaults.string(forKey: "lastUpdate") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let date = Date()
            let last = dateFormatter.date(from: lastUpdate)!
            if date.timeIntervalSince(last) > Constants.songsUpdateInterval {
                return true
            }
        } else {
            return true
        }
        
        return false
    }
    
    private static func setLastUpdate(_ defaults: UserDefaults) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        defaults.set(formatter.string(from: Date()), forKey: "lastUpdate")
    }
}
