//
//  SongBookDataSource.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 12/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

class SongBookDataSource: NSObject {
    
    private let context: NSManagedObjectContext
    
    private var allSongBooks: [SongBook]
    private var showingSongBooks: [SongBook]
    
    var showingCount: Int { return showingSongBooks.count }

    var searchText: String
    
    override init() {
        context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.parent = PersistenceService.context
        
        allSongBooks = []
        showingSongBooks = []
        
        searchText = ""
        
        super.init()
    }
    
    func songBook(at index: Int) -> SongBook {
        return showingSongBooks[index]
    }
}

// MARK: - Data Handlers

extension SongBookDataSource {
    
    func showAll(_ completionHandler: @escaping () -> Void) {
        self.searchText = ""
        
        context.perform {
            if self.allSongBooks.count == 0 {
                self.loadData()
            }
            
            self.showingSongBooks = self.allSongBooks
            
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
               self.showingSongBooks = self.allSongBooks
            }
            
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    private func loadData() {
        let predicate = NSPredicate(format: "isPrivate == false")
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        
        if let data: [SongBook] = CoreDataService.fetchData(predicate: predicate, sortDescriptors: sortDescriptors, context: context) {
            self.allSongBooks = data
        } else {
            self.allSongBooks = []
        }
    }
    
    private func search() {
        showingSongBooks = []
        
        let predicates = [
            NSPredicate(format: "name BEGINSWITH[c] %@", searchText),
            NSPredicate(format: "name BEGINSWITH[cd] %@", searchText),
            NSPredicate(format: "shortcut BEGINSWITH[cd] %@", searchText),
            NSPredicate(format: "name CONTAINS[c] %@", searchText),
            NSPredicate(format: "name CONTAINS[cd] %@", searchText)
        ]
        
        for predicate in predicates {
            showingSongBooks.append(contentsOf: allSongBooks.filter {
                predicate.evaluate(with: $0) && !showingSongBooks.contains($0)
            })
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SongBookDataSource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showingCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "songBookCell", for: indexPath) 
        
        if indexPath.row < showingCount {
            setCell(cell, showingSongBooks[indexPath.row])
        }
        
        return cell
    }
    
    private func setCell(_ cell: UICollectionViewCell, _ songBook: SongBook) {
        guard let cell = cell as? SongBookCell else { return }
        
        cell.songBookName = songBook.name
    }
}
