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

extension SongBook: SongDataSource {
    
    func setCell(_ cell: UITableViewCell) {
        guard let cell = cell as? SongBookCell else { return }
        
        cell.shortcutLabel.text = shortcut
        cell.nameLabel.text = name
        cell.shortcutBackgroundColor = .from(hex: color)
    }
    
    static func registerCell(_ tableView: UITableView, forCellReuseIdentifier identifier: String) {
        tableView.register(SongBookCell.self, forCellReuseIdentifier: identifier)
    }
    
    static func getPredicates(forSearchText searchText: String) -> [NSPredicate] {
        let predicates = [
            NSPredicate(format: "name BEGINSWITH[cd] %@", searchText),
            NSPredicate(format: "shortcut BEGINSWITH[cd] %@ AND NOT name CONTAINS[cd] %@", searchText, searchText),
            NSPredicate(format: "name CONTAINS[cd] %@ AND NOT name BEGINSWITH[cd] %@", searchText, searchText)
        ]
        
        return predicates
    }
}
