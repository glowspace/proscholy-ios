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

            return songBookRecords.map {$0.songBook!.shortcut! + $0.number!}
        }
    }
}

extension SongLyric: SongDataSource {
    
    func setCell(_ cell: UITableViewCell) {
        guard let cell = cell as? SongLyricCell else { return }
        
        cell.nameLabel.text = name
        cell.numberLabel.text = id!
    }
    
    static func registerCell(_ tableView: UITableView, forCellReuseIdentifier identifier: String) {
        tableView.register(SongLyricCell.self, forCellReuseIdentifier: identifier)
    }
    
    static func getPredicates(forSearchText searchText: String) -> [NSPredicate] {
        let predicates = [
            NSPredicate(format: "name BEGINSWITH[cd] %@", searchText),
            NSPredicate(format: "NOT name BEGINSWITH[cd] %@ AND name CONTAINS[cd] %@", searchText, searchText),
            NSPredicate(format: "ANY numbers CONTAINS[cd] %@", searchText)
        ]
        
        return predicates
    }
}
