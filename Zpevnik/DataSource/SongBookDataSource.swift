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
    
    var data: [SongBook]
    var showingData: [SongBook]
    
    var searchText: String? {
        didSet {
            updateData()
        }
    }
    
    override init() {
        if let data: [SongBook] = CoreDataService.fetchData(predicate: NSPredicate(format: "isPrivate == false"), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))], context: PersistenceService.context) {
            self.data = data
        } else {
            data = []
        }
        
        showingData = data
        
        super.init()
    }

    // MARK: - Data Handlers
    
    private func search(searchText: String) {
        let predicates = [
            NSPredicate(format: "name BEGINSWITH[cd] %@", searchText),
            NSPredicate(format: "shortcut BEGINSWITH[cd] %@ AND NOT name CONTAINS[cd] %@", searchText, searchText),
            NSPredicate(format: "name CONTAINS[cd] %@ AND NOT name BEGINSWITH[cd] %@", searchText, searchText)
        ]
        
        showingData = []
        
        for predicate in predicates {
            showingData.append(contentsOf: data.filter {
                predicate.evaluate(with: $0) && !showingData.contains($0)
            })
        }
    }
    
    func updateData() {
        if let searchText = searchText, searchText.count > 0 {
            search(searchText: searchText)
        } else {
            showingData = data
        }
    }
    
    // Mark: - Cell Settings
    
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
}
