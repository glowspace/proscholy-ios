//
//  SongLyricDataSource.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 12/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

class SongLyricDataSource: NSObject {
    
    private let context: NSManagedObjectContext
    
    private var allSongLyrics: [SongLyric]
    var showingSongLyrics: [SongLyric]
    
    var searchText: String
    
    override init() {
        context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = PersistenceService.context
        
        allSongLyrics = []
        showingSongLyrics = []
        
        searchText = ""
        
        super.init()
    }
    
    func updateData(_ searchText: String? = nil, _ completionHandler: @escaping () -> Void) {
        self.searchText = searchText ?? ""
        
        context.perform {
            if self.searchText.count > 0 {
                self.search()
            } else {
                if self.allSongLyrics.count == 0 {
                    self.loadData()
                }
                
                self.showingSongLyrics = self.allSongLyrics
            }
            
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    private func loadData() {
        let predicate = NSPredicate(format: "lyrics != nil")
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        
        if let data: [SongLyric] = CoreDataService.fetchData(predicate: predicate, sortDescriptors: sortDescriptors, context: context) {
            self.allSongLyrics = data
        } else {
            self.allSongLyrics = []
        }
    }
    
    private func search() {
        showingSongLyrics = []
        
        let predicates = [
            NSPredicate(format: "name BEGINSWITH[cd] %@", searchText),
            NSPredicate(format: "name CONTAINS[cd] %@", searchText, searchText)
        ]
        
        for predicate in predicates {
            showingSongLyrics.append(contentsOf: allSongLyrics.filter {
                predicate.evaluate(with: $0) && !showingSongLyrics.contains($0)
            })
        }
        
        var dataContainingId = allSongLyrics.filter {
            let numbers: [String]
            
            numbers = $0.numbers
            
            return NSPredicate(format: "ANY %@ CONTAINS[cd] %@", numbers, searchText).evaluate(with: nil) && !showingSongLyrics.contains($0)
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
        
        showingSongLyrics.append(contentsOf: dataContainingId)
        
        showingSongLyrics.append(contentsOf: allSongLyrics.filter {
            NSPredicate(format: "lyricsNoChords CONTAINS[cd] %@", searchText).evaluate(with: $0) && !showingSongLyrics.contains($0)
        })
    }
}

// MARK: - UITableViewDataSource

extension SongLyricDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingSongLyrics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        
        if indexPath.row < showingSongLyrics.count {
            setCell(cell, showingSongLyrics[indexPath.row])
        }
        
        return cell
    }
    
    private func setCell(_ cell: UITableViewCell, _ songLyric: SongLyric) {
        guard let cell = cell as? SongLyricCell else { return }
        
        cell.favorite = false
        cell.nameLabel.text = songLyric.name
        cell.numberLabel.text = songLyric.id
        
        let predicate = NSPredicate(format: "self CONTAINS[cd] %@", searchText)
        let numbers = songLyric.numbers.filter {
            predicate.evaluate(with: $0)
        }

        if numbers.count > 0 && !songLyric.id!.contains(searchText) {
            cell.numberLabel.text = numbers[0]
        } else {
            cell.numberLabel.text = songLyric.id
        }
            
    //        if let songBook = songBook {
    //            if let number = songLyric.getNumber(in: songBook) {
    //                cell.numberLabel.text = number
    //            }
    //        }
    }
}
