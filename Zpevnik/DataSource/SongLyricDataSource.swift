//
//  SongLyricDataSource.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 12/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

class SongLyricDataSource: NSObject, DataSource {
    
    var songBook: SongBook?
    var searchText: String?
    
    func setCell(_ cell: UITableViewCell, _ object: NSManagedObject) {
        guard let cell = cell as? SongLyricCell else { return }
        guard let songLyric = object as? SongLyric else { return }

        cell.nameLabel.text = songLyric.name
        cell.numberLabel.text = songLyric.id
        
        if let searchText = searchText {
            let predicate = NSPredicate(format: "self CONTAINS[cd] %@", searchText)
            let numbers = songLyric.numbers.filter {
                predicate.evaluate(with: $0)
            }
            
            if numbers.count > 0 && !songLyric.id!.contains(searchText) {
                cell.numberLabel.text = numbers[0]
            } else {
                cell.numberLabel.text = songLyric.id
            }
        }
        
        if let songBook = songBook {
            let numbers = songLyric.numbers.filter { $0.contains(songBook.shortcut!) }
            if numbers.count == 1 {
                cell.numberLabel.text = numbers[0]
            }
        }
    }
    
    func registerCell(_ tableView: UITableView, forCellReuseIdentifier identifier: String) {
        tableView.register(SongLyricCell.self, forCellReuseIdentifier: identifier)
    }
    
    func getPredicates(forSearchText searchText: String) -> [NSPredicate] {
        let predicates = [
            NSPredicate(format: "name BEGINSWITH[cd] %@", searchText),
            NSPredicate(format: "NOT name BEGINSWITH[cd] %@ AND name CONTAINS[cd] %@", searchText, searchText),
            NSPredicate(format: "ANY numbers CONTAINS[cd] %@", searchText),
            NSPredicate(format: "lyrics CONTAINS[cd] %@", searchText)
        ]

        return predicates
    }
}
