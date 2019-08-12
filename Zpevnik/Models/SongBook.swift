//
//  SongBook.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 27/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

extension SongBook {
    
    static func createFromDict(_ data: [String: Any], _ context: NSManagedObjectContext) -> SongBook? {
        guard let id = data["id"] as? String else { return nil }
        
        guard let songBook: SongBook = CoreDataService.createOrGetObject(id: id, context: context) else { return nil }
        
        songBook.id = id
        songBook.name = data["name"] as? String
        songBook.shortcut = data["shortcut"] as? String
        songBook.isPrivate = data["is_private"] as? Bool ?? true
        songBook.color = data["color"] as? String
        
        return songBook
    }
}
