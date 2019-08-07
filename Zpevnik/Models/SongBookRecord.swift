//
//  SongBookRecord.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 06/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import CoreData

extension SongBookRecord {
    
    static func createFromDict(_ data: [String: Any], _ context: NSManagedObjectContext) -> SongBookRecord? {
        guard let id = data["id"] as? String else { return nil }
        
        guard let songBookRecord: SongBookRecord = CoreDataService.createOrGetObject(id: id, context: context) else { return nil }

        songBookRecord.id = id
        songBookRecord.number = data["number"] as? String
        
        if let songBookData = data["songbook"] as? [String: String], let songBookId = songBookData["id"] {
            if let songBook: SongBook = CoreDataService.createOrGetObject(id: songBookId, context: context) {
                songBookRecord.songBook = songBook
                songBook.addToRecords(songBookRecord)
            }
        }
        
        return songBookRecord
    }
}
