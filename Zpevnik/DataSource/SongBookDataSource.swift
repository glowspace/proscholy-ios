//
//  SongBookDataSource.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 12/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

class SongBookDataSource: NSObject, DataSource {
    
    func setCell(_ cell: UITableViewCell, _ object: NSManagedObject) {
        guard let cell = cell as? SongBookCell else { return }
        guard let songBook = object as? SongBook else { return }
        
        cell.shortcutLabel.text = songBook.shortcut
        cell.nameLabel.text = songBook.name
        cell.shortcutBackgroundColor = .from(hex: songBook.color)
    }
    
    func registerCell(_ tableView: UITableView, forCellReuseIdentifier identifier: String) {
        tableView.register(SongBookCell.self, forCellReuseIdentifier: identifier)
    }
    
    func getPredicates(forSearchText searchText: String) -> [NSPredicate] {
        let predicates = [
            NSPredicate(format: "name BEGINSWITH[cd] %@", searchText),
            NSPredicate(format: "shortcut BEGINSWITH[cd] %@ AND NOT name CONTAINS[cd] %@", searchText, searchText),
            NSPredicate(format: "name CONTAINS[cd] %@ AND NOT name BEGINSWITH[cd] %@", searchText, searchText)
        ]
        
        return predicates
    }
}
