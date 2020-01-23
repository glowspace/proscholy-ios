//
//  Song.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 08/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import CoreData

extension Song {
    
    static func createFromDict(_ data: [String: Any], _ context: NSManagedObjectContext) -> Song? {
        guard let id = data["id"] as? String else { return nil }
        
        guard let song: Song = CoreDataService.createOrGetObject(id: id, context: context) else { return nil }
        
        song.id = id
        song.name = data["name"] as? String
        
        return song
    }
}

extension Song {
    
    var original: SongLyric? {
        get {
            if let songLyrics = songLyrics?.allObjects as? [SongLyric] {
                for songLyric in songLyrics {
                    if songLyric.type == 0 {
                        return songLyric
                    }
                }
            }
            
            return nil
        }
    }
}
