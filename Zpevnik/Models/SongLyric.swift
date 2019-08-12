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
        
        songLyric.id = id
        songLyric.name = data["name"] as? String
        songLyric.lyrics = data["lyrics"] as? String
        songLyric.language = data["lang_string"] as? String
        songLyric.isOriginal = data["type"] as? Int ?? 1 == 0 
        
        return songLyric
    }
}

extension SongLyric {
    
    func isFavorite() -> Bool {
        return favoriteOrder > -1
    }
    
    @objc var numbers: [String] {
        get {
            guard let songBookRecords = songBookRecords?.allObjects as? [SongBookRecord] else { return [] }
            
            var numbers = songBookRecords.map {$0.songBook!.shortcut! + $0.number!}
            numbers.append(id!)
            
            return numbers
        }
    }
}
