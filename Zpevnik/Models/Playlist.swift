//
//  Playlist.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

extension Playlist {
    
    static func createFromDict(_ data: [String: Any], _ context: NSManagedObjectContext) -> Playlist? {
        guard let id = data["id"] as? String else { return nil }
        
        guard let playlist: Playlist = CoreDataService.createOrGetObject(id: id, context: context) else { return nil }
        
        playlist.id = id
        playlist.name = data["name"] as? String
        
        return playlist
    }
    
    static func create(_ id: String, _ name: String, _ user: User) -> Playlist? {
        guard let entityName = Playlist.entity().name, let playlist = NSEntityDescription.insertNewObject(forEntityName: entityName, into: PersistenceService.backgroundContext) as? Playlist else { return nil }
        
        playlist.id = id
        playlist.name = name
        playlist.user = user
        
        user.addToPlaylists(playlist)
        
        return playlist
    }
}
