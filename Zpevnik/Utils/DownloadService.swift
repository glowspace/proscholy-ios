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
            downloadSongData(updater, completionHandler)
        } else {
            loadSongDataFromFile(updater, completionHandler)
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
            Query(type: "song_lyrics", fields: ["id", "lyrics", "name", Query(type: "songbook_records", fields: ["id", "number", Query(type: "songbook", fields: ["id"])]), Query(type: "authors", fields: ["id", "name"])], arguments: arguments),
            Query(type: "songbooks", fields: ["id", "name", "shortcut", "is_private", "color"])
        ]
        let urlString = generateQuery("https://zpevnik.proscholy.cz", queries)
        
        guard let encodedUrl = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encodedUrl) else { return }
        
        updater("Aktualizace databáze písní.")
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        
        let task = URLSession(configuration: sessionConfig).dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                completionHandler()
                return
            }
            guard let data = data else { return }
            
            do {
                updater("Příprava písní")
                
                try prepareData(data)
                
                setLastUpdate(defaults)
                
                completionHandler()
            } catch {
                completionHandler()
            }
        }
        
        task.resume()
    }
    
    private static func loadSongDataFromFile( _ updater: @escaping (String) -> Void, _ completionHandler: @escaping () -> Void) {
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "defaultDataLoaded") || defaults.string(forKey: "lastUpdate") != nil {
            completionHandler()
            return
        }
        
        do {
            guard let path = Bundle.main.path(forResource: "data", ofType: "json") else { return }
            try prepareData(try Data(contentsOf: URL(fileURLWithPath: path)))
            
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
    
    // MARK: - Objects Parsing
    
    private static func createSongBooks(from data: [[String: Any]]?, _ context: NSManagedObjectContext) {
        guard let data = data else { return }

        for songBookData in data {
            _ = SongBook.createFromDict(songBookData, context)
        }
    }
    
    private static func createSongLyrics(from data: [[String: Any]]?, _ context: NSManagedObjectContext) {
        guard let data = data else { return }

        for songLyricsData in data {
            if let songLyric = SongLyric.createFromDict(songLyricsData, context) {
                createSongBookRecords(songLyricsData["songbook_records"], forSongLyric: songLyric, context: context)

                createAuthors(songLyricsData["authors"], forSongLyric: songLyric, context: context)
            }
        }
    }

    private static func createSongBookRecords(_ data: Any?, forSongLyric songLyric: SongLyric, context: NSManagedObjectContext) {
        guard let data = data as? [[String: Any]] else { return }

        for songBookRecordData in data {
            if let songBookRecord = SongBookRecord.createFromDict(songBookRecordData, context) {
                songBookRecord.songLyric = songLyric
                songLyric.addToSongBookRecords(songBookRecord)
            }
        }
    }

    private static func createAuthors(_ data: Any?, forSongLyric songLyric: SongLyric, context: NSManagedObjectContext) {
        guard let data = data as? [[String: Any]] else { return }

        for authorData in data {
            if let author = Author.createFromDict(authorData, context) {
                author.addToSongLyrics(songLyric)
                songLyric.addToAuthors(author)
            }
        }
    }
    
    // MARK: - Help Functions
    
    private static func generateQuery(_ baseUrl: String, _ queries: [Query]) -> String {
        var url = baseUrl + "/graphql?query={"
        
        for query in queries {
            url += query.generate()
        }
        
        url += "}"
        
        return url
    }
    
    private static func setLastUpdate(_ defaults: UserDefaults) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        defaults.set(formatter.string(from: Date()), forKey: "lastUpdate")
    }
}
