//
//  SongLyric.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 27/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

extension SongLyric {

    func isFavorite() -> Bool {
        return favoriteOrder > -1
    }
}

extension SongLyric: SongDataSource {
    
    func setCell(_ cell: UITableViewCell) {
        guard let cell = cell as? SongLyricCell else { return }
        
        cell.nameLabel.text = name
        cell.numberLabel.text = id!
    }
    
    static func getEntityName() -> String {
        return "SongLyric"
    }
    
    static func registerCell(_ tableView: UITableView, forCellReuseIdentifier identifier: String) {
        tableView.register(SongLyricCell.self, forCellReuseIdentifier: identifier)
    }
    
    static func getPredicates(forSearchText searchText: String) -> [NSPredicate] {
        let predicates = [
            NSPredicate(format: "name BEGINSWITH[cd] %@", searchText),
            NSPredicate(format: "NOT name BEGINSWITH[cd] %@ AND name CONTAINS[cd] %@", searchText, searchText)
        ]
        
        return predicates
    }
}
