//
//  SongLyric.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 27/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

extension SongLyric {
    
    static func createFromDict(_ data: [String: Any], _ context: NSManagedObjectContext) -> SongLyric? {
        guard let id = data["id"] as? String else { return nil }
        
        guard let songLyric: SongLyric = CoreDataService.createOrGetObject(id: id, context: context) else { return nil }
        
        if let trashed = data["trashed"] as? Bool, trashed {
            context.delete(songLyric)
            
            return nil
        }
        
        songLyric.id = id
        songLyric.name = data["name"] as? String
        songLyric.lyrics = data["lyrics"] as? String
        songLyric.language = data["lang_string"] as? String
        songLyric.type = data["type"] as? Int16 ?? 0
        
        return songLyric
    }
}

extension SongLyric {
    
    func isFavorite() -> Bool {
        return favoriteOrder > -1
    }
    
    func hasTranslations() -> Bool {
        return (song?.songLyrics?.count ?? 0) > 1
    }
    
    func musicalNotesURL() -> URL? {
        if let files = files?.allObjects as? [File] {
            for file in files {
                if file.typeString == "noty", let url = file.url {
                    return URL(string: url)
                }
            }
        }
        
        return nil
    }
    
    func getNumber(in songBook: SongBook) -> String? {
        if let songBookRecords = songBookRecords?.allObjects as? [SongBookRecord] {
            for songBookRecord in songBookRecords {
                if songBookRecord.songBook == songBook {
                    return (songBook.shortcut ?? "") + songBookRecord.number!
                }
            }
        }
        
        return nil
    }
    
    @objc var numbers: [String] {
        get {            
            guard let songBookRecords = songBookRecords?.allObjects as? [SongBookRecord] else { return [] }

            var numbers = songBookRecords.map {($0.songBook!.shortcut ?? "") + $0.number!}
            numbers.append(id!)

            return numbers
        }
    }
    
    @objc var lyricsNoChords: String {
        get {
            return lyrics!.replacingOccurrences(of: #"(\[([^\s\]])+\])"#, with: "", options: [.regularExpression])
        }
    }
}
