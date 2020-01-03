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
    private var showingSongLyrics: [SongLyric]
    
    var showingCount: Int { return showingSongLyrics.count }
    
    private let lastSearchedKey: String
    var searchText: String
    
    init(_ lastSearchedKey: String) {
        context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = PersistenceService.context
        
        allSongLyrics = []
        showingSongLyrics = []
        
        self.lastSearchedKey = lastSearchedKey
        searchText = ""
        
        super.init()
    }
    
    func allFavorite(_ indexes: [Int]) -> Bool {
        for i in indexes {
            if showingSongLyrics[i].isFavorite() == false {
                return false
            }
        }
        
        return indexes.count > 0
    }
    
    func toggleFavorites(_ indexes: [Int]) -> Bool {
        if indexes.count == 0 { return false }
        
        let favorite = allFavorite(indexes)
        
        for i in indexes {
            if favorite {
                showingSongLyrics[i].favoriteOrder = -1
            } else {
                showingSongLyrics[i].favoriteOrder = Int16(UserSettings.favoriteOrderLast)
            }
        }
        
        do {
            try context.save()
        } catch { }
        
        return !favorite
    }
    
    func songLyric(at index: Int) -> SongLyric? {
        return showingSongLyrics[index]
    }
}

// MARK: - Data Handlers

extension SongLyricDataSource {
    
    func showAll(_ completionHandler: @escaping () -> Void) {
        self.searchText = ""
        
        context.perform {
            if self.allSongLyrics.count == 0 {
                self.loadData()
            }
            
            self.showingSongLyrics = self.allSongLyrics
            
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    func search(_ searchText: String?, _ completionHandler: @escaping () -> Void) {
        self.searchText = searchText ?? ""
        
        context.perform {
            if self.searchText.count > 0 {
                self.search()
            } else {
                self.showLastSearched()
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
            NSPredicate(format: "name BEGINSWITH[c] %@", searchText),
            NSPredicate(format: "name BEGINSWITH[cd] %@", searchText),
            NSPredicate(format: "name CONTAINS[c] %@", searchText, searchText),
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
    
    private func showLastSearched() {
        let defaults = UserDefaults.standard
        
        let lastSearched = defaults.array(forKey: "lastSearchedHome") as? [String] ?? []
        
        showingSongLyrics = allSongLyrics.filter {
            lastSearched.contains($0.id!)
        }.sorted {
            lastSearched.firstIndex(of: $0.id!)! > lastSearched.firstIndex(of: $1.id!)!
        }
    }
}

// MARK: - UITableViewDataSource

extension SongLyricDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songLyricCell", for: indexPath)
        
        if indexPath.row < showingCount {
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
    }
}
