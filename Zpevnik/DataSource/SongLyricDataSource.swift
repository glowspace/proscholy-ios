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
    
    var data: [SongLyric]
    var showingData: [SongLyric]
    
    var searchText: String? {
        didSet {
            updateData()
        }
    }
    
    var activeFilters: [Bool]?
    var selectedTags: [[FilterAble]]? {
        didSet {
            updateData()
        }
    }
    
    var songBook: SongBook?
    var favorite: Bool
    
    init(songBook: SongBook) {
        self.songBook = songBook
        self.favorite = false
        
        if let records = songBook.records?.allObjects as? [SongBookRecord] {
            data = records.map { $0.songLyric! }
            data = data.filter { $0.lyrics != nil }
            data.sort { (first, second) in
                if let firstNumber = first.getNumber(in: songBook), let secondNumber = second.getNumber(in: songBook) {
                    return firstNumber.compare(secondNumber, options: .numeric) == .orderedAscending
                }
                
                return false
            }
        } else {
            data = []
        }
        
        showingData = data
        
        super.init()
    }
    
    init(favorite: Bool = false) {
        self.favorite = favorite
        
        let predicate = favorite ? NSPredicate(format: "favoriteOrder != -1") : NSPredicate(format: "lyrics != nil")
        let sortDescriptors = favorite ? [NSSortDescriptor(key: "favoriteOrder", ascending: true)] : [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        
        if let data: [SongLyric] = CoreDataService.fetchData(predicate: predicate, sortDescriptors: sortDescriptors, context: PersistenceService.context) {
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
            NSPredicate(format: "name CONTAINS[cd] %@", searchText, searchText)
        ]
        
        showingData = []
        
        for predicate in predicates {
            showingData.append(contentsOf: data.filter {
                predicate.evaluate(with: $0) && !showingData.contains($0)
            })
        }
        
        var dataContainingId = data.filter {
            let numbers: [String]
            
            if let songBook = songBook {
                numbers = [$0.getNumber(in: songBook) ?? ""]
            } else {
                numbers = $0.numbers
            }
            
            return NSPredicate(format: "ANY %@ CONTAINS[cd] %@", numbers, searchText).evaluate(with: nil) && !showingData.contains($0)
        }
        
        dataContainingId.sort { (first, second) in
            let predicate = NSPredicate(format: "self CONTAINS[cd] %@", searchText)
            
            let firstNumbers = first.numbers.filter {
                predicate.evaluate(with: $0)
            }
            
            let secondNumbers = second.numbers.filter {
                predicate.evaluate(with: $0)
            }
            
            let firstShowingNumber: String, secondShowingNumber: String
            
            if firstNumbers.count > 0 && !first.id!.contains(searchText) {
                firstShowingNumber = firstNumbers[0]
            } else {
                firstShowingNumber = first.id!
            }
            
            if secondNumbers.count > 0 && !second.id!.contains(searchText) {
                secondShowingNumber = secondNumbers[0]
            } else {
                secondShowingNumber = second.id!
            }
            
            return firstShowingNumber.compare(secondShowingNumber, options: .numeric) == .orderedAscending
        }
        
        showingData.append(contentsOf: dataContainingId)
        
        showingData.append(contentsOf: data.filter {
            NSPredicate(format: "lyricsNoChords CONTAINS[cd] %@", searchText).evaluate(with: $0) && !showingData.contains($0)
        })
    }
    
    func updateData() {        
        if let searchText = searchText, searchText.count > 0 {
            search(searchText: searchText)
        } else {
            showingData = data
        }
        
        filterData()
    }
    
    private func filterData() {
        guard let selectedTags = selectedTags, let activeFilters = activeFilters else { return }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: selectedTags.enumerated().map {
            let (i, tags) = $0
            let predicateFormat: String
            
            if tags is [Tag] {
                predicateFormat = Tag.predicateFormat
            } else if tags is [Language] {
                predicateFormat = Language.predicateFormat
            } else {
                predicateFormat = ""
            }
            
            return NSPredicate(format: predicateFormat + " OR %d == 1", tags.map { $0.name }, activeFilters[i] ? 0 : 1)
        })
        
        showingData = showingData.filter {
            predicate.evaluate(with: $0)
        }
    }
    
    // Mark: - Cell Settings
    
    func setCell(_ cell: UITableViewCell, _ object: NSManagedObject) {
        guard let cell = cell as? SongLyricCell else { return }
        guard let songLyric = object as? SongLyric else { return }

        cell.favorite = favorite
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
            if let number = songLyric.getNumber(in: songBook) {
                cell.numberLabel.text = number
            }
        }
    }
    
    func registerCell(_ tableView: UITableView, forCellReuseIdentifier identifier: String) {
        tableView.register(SongLyricCell.self, forCellReuseIdentifier: identifier)
    }
}
