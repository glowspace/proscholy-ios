//
//  SongBook.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 27/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

extension SongBook: SongDataSource {
    
    func setCell(_ cell: UITableViewCell) {
        guard let cell = cell as? SongBookCell else { return }
        
        cell.shortcutLabel.text = shortcut
        cell.nameLabel.text = name
    }
    
    static func getEntityName() -> String {
        return "SongBook"
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
