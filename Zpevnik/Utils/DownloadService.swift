//
//  DownloadService.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import CoreData

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

class DownloadService {
    
    private init() { }
    
    static var observation: NSKeyValueObservation?
    
    static func updateSongs(_ updater: @escaping (String) -> Void, _ completionHandler: @escaping () -> Void) {
        if Reachability.networkIsReachableOverWifi() {
            downloadSongData(prepareData(_:), updater, completionHandler)
        } else {
            loadSongDataFromFile(prepareData(_:), updater, completionHandler)
        }
    }
    
    private static func downloadSongData(_ handler: @escaping (Data) throws -> (), _ updater: @escaping (String) -> Void, _ completionHandler: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        var arguments = [String: String]()
        if let last_update = defaults.string(forKey: "last_update") {
            arguments["updated_after"] = last_update
        }
        
        let queries = [
            Query(type: "song_lyrics", fields: ["id", "lyrics", "name", Query(type: "songbook_records", fields: ["id", "number", Query(type: "songbook", fields: ["id"])]), Query(type: "authors", fields: ["id", "name"])], arguments: arguments),
            Query(type: "songbooks", fields: ["id", "name", "shortcut"])
        ]
        let urlString = generateQuery("https://zpevnik.proscholy.cz", queries)
        
        guard let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else { return }
        
        updater("Aktualizace databáze písní.")
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return }
            guard let data = data else { return }
            
            do {
                updater("Příprava písní")
                
                try handler(data)
                
                setLastUpdate(defaults)
                
                completionHandler()
            } catch { }
        }.resume()
    }
    
    private static func loadSongDataFromFile(_ handler: @escaping (Data) throws -> (), _ updater: @escaping (String) -> Void, _ completionHandler: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "defaultDataLoaded") || defaults.string(forKey: "last_update") != nil {
            completionHandler()
            return
        }
        
        do {
            guard let path = Bundle.main.path(forResource: "data", ofType: "json") else { return }
            try handler(try Data(contentsOf: URL(fileURLWithPath: path)))
            
            defaults.set(true, forKey: "defaultDataLoaded")
            
            completionHandler()
        } catch { }
    }
    
    private static func prepareData(_ data: Data) throws {
        guard let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
        
        let context = PersistenceService.persistentContainer.newBackgroundContext()
        
        guard let data = jsonData["data"] as? [String: Any] else { return }
        
        createSongBooks(from: data["songbooks"] as? [[String: Any]], context)
        createSongLyrics(from: data["song_lyrics"] as? [[String: Any]], context)
        
        try context.save()
    }
    
    private static func setLastUpdate(_ defaults: UserDefaults) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        defaults.set(formatter.string(from: Date()), forKey: "last_update")
    }
    
    private static func createSongBooks(from data: [[String: Any]]?, _ context: NSManagedObjectContext) {
        guard let data = data else { return }
        
        for songBookData in data {
            guard let id = songBookData["id"] as? String else { return }
            
            let songBook: SongBook
            
            if let songBooks = CoreDataService.fetchData(entityName: "SongBook", predicate: NSPredicate(format: "id = %@", id), context: context) as? [SongBook], songBooks.count == 1 {
                songBook = songBooks[0]
            } else {
                songBook = NSEntityDescription.insertNewObject(forEntityName: "SongBook", into: context) as! SongBook
            }
            
            songBook.id = id
            songBook.name = songBookData["name"] as? String
            songBook.shortcut = songBookData["shortcut"] as? String
        }
    }
    
    private static func createSongLyrics(from data: [[String: Any]]?, _ context: NSManagedObjectContext) {
        guard let data = data else { return }
        
        for songLyricsData in data {
            guard let id = songLyricsData["id"] as? String else { return }
            
            let songLyric: SongLyric
            
            if let songs = CoreDataService.fetchData(entityName: "SongLyric", predicate: NSPredicate(format: "id = %@", id), context: context) as? [SongLyric], songs.count == 1 {
                songLyric = songs[0]
            } else {
                songLyric = NSEntityDescription.insertNewObject(forEntityName: "SongLyric", into: context) as! SongLyric
            }
            
            songLyric.id = id
            songLyric.name = songLyricsData["name"] as? String
            songLyric.lyrics = songLyricsData["lyrics"] as? String
            
            if let songBookRecordsData = songLyricsData["songbook_records"] as? [[String: Any]] {
                for songBookRecordData in songBookRecordsData {
                    guard let songBookRecordId = songBookRecordData["id"] as? String else { return }
                    
                    let songBookRecord: SongBookRecord
                    
                    if let songBookRecords = CoreDataService.fetchData(entityName: "SongBookRecord", predicate: NSPredicate(format: "id = %@", songBookRecordId), context: context) as? [SongBookRecord], songBookRecords.count == 1 {
                        songBookRecord = songBookRecords[0]
                    } else {
                        songBookRecord = NSEntityDescription.insertNewObject(forEntityName: "SongBookRecord", into: context) as! SongBookRecord
                    }
                    
                    songBookRecord.id = songBookRecordId
                    songBookRecord.number = songBookRecordData["number"] as? String
                    
                    let songBookId = (songBookRecordData["songbook"] as! [String: String])["id"]!
                    
                    if let songBooks = CoreDataService.fetchData(entityName: "SongBook", predicate: NSPredicate(format: "id == %@", songBookId), context: context) as? [SongBook], songBooks.count == 1 {
                        songBookRecord.songBook = songBooks[0]
                        songBooks[0].addToRecords(songBookRecord)
                    }
                    
                    songBookRecord.songLyric = songLyric
                    songLyric.addToSongbookRecords(songBookRecord)
                }
            }
            
            if let authorsData = songLyricsData["authors"] as? [[String: Any]] {
                for authorData in authorsData {
                    guard let authorId = authorData["id"] as? String else { return }
                    
                    let author: Author
                    
                    if let authors = CoreDataService.fetchData(entityName: "Author", predicate: NSPredicate(format: "id = %@", authorId), context: context) as? [Author], authors.count == 1 {
                        author = authors[0]
                    } else {
                        author = NSEntityDescription.insertNewObject(forEntityName: "Author", into: context) as! Author
                    }
                    
                    author.id = authorId
                    author.name = authorData["name"] as? String
                    
                    author.addToSongLyrics(songLyric)
                    songLyric.addToAuthors(author)
                }
            }
        }
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
