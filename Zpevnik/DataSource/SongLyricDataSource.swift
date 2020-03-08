//
//  SongLyricDataSource.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 12/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

// MARK: - FavoriteSongLyricDataSource

class FavoriteSongLyricDataSource: ReorderableSongLyricDataSource {
    
    override var title: String? { "Písně s hvězdičkou" }
    
    init() {
        super.init()
        
        canShowStar = false
    }
    
    override func loadData() {
        let predicate = NSPredicate(format: "lyrics != nil and favoriteOrder > -1")
        let sortDescriptors = [NSSortDescriptor(key: "favoriteOrder", ascending: true)]
        
        if let data: [SongLyric] = CoreDataService.fetchData(predicate: predicate, sortDescriptors: sortDescriptors, context: PersistenceService.backgroundContext) {
            self.allSongLyrics = data
        } else {
            self.allSongLyrics = []
        }
    }
}

// MARK: - PlaylistSongLyricDataSource

class PlaylistSongLyricDataSource: ReorderableSongLyricDataSource {
    
    private let playlist: Playlist
    
    override var title: String? { playlist.name }
    
    init(_ playlist: Playlist) {
        self.playlist = playlist
        
        super.init()
    }
    
    override func loadData() {
        if let songLyrics = playlist.songLyrics?.allObjects as? [SongLyric] {
            allSongLyrics = songLyrics
        }
    }
}

// MARK: - ReorderableSongLyricDataSource

class ReorderableSongLyricDataSource: SongLyricDataSource {
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
}

// MARK: - SongBooksSongLyricDataSource

class SongBooksSongLyricDataSource: SongLyricDataSource {
    
    private let songBook: SongBook
    
    override var title: String? { songBook.name }
    
    override var idPredicate: NSPredicate { NSPredicate(format: "self CONTAINS[cd] %@", songBook.shortcut ?? searchText) }
    
    init(_ songBook: SongBook) {
        self.songBook = songBook
        
        super.init()
    }
    
    override func loadData() {
        guard let records = songBook.records?.allObjects as? [SongBookRecord] else { return }
        
        allSongLyrics = []
        
        for record in records {
            if let songLyric = record.songLyric, songLyric.lyrics != nil {
                allSongLyrics.append(songLyric)
            }
        }
    }
}

// MARK: - SongLyricDataSource

class SongLyricDataSource: NSObject {
    
    internal var allSongLyrics: [SongLyric]
    private var songLyricsBeforeFilter: [SongLyric]
    private var showingSongLyrics: [SongLyric]
    
    var showingCount: Int { return showingSongLyrics.count }
    
    internal var canShowStar = true
    
    private let lastSearchedKey: String?
    var searchText: String
    
    var filterTagDataSource: FilterTagDataSource?
    
    var currentSongLyricIndex: Int?
    
    var title: String? { nil }
    
    var idPredicate: NSPredicate { NSPredicate(format: "self CONTAINS[cd] %@", searchText) }
    
    var currentSongLyric: SongLyric? {
        guard let currentIndex = currentSongLyricIndex else { return nil }
        
        return showingSongLyrics[currentIndex]
    }
    
    init(_ lastSearchedKey: String? = nil) {
        allSongLyrics = []
        songLyricsBeforeFilter = []
        showingSongLyrics = []
        
        searchText = ""
        self.lastSearchedKey = lastSearchedKey
        
        super.init()
        
        loadData()
    }
    
    // MARK: - Data Handlers
    
    func showAll(_ completionHandler: @escaping () -> Void) {
        self.searchText = ""
        
        PersistenceService.backgroundContext.perform {
            self.songLyricsBeforeFilter = self.allSongLyrics
            
            self.filterData()
            
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    func search(_ searchText: String?, _ completionHandler: @escaping () -> Void) {
        self.searchText = searchText ?? ""
        
        PersistenceService.backgroundContext.perform {
            if self.searchText.count > 0 {
                self.search()
                self.filterData()
            } else {
                self.showLastSearched()
            }
            
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    func filter(_ completionHandler: @escaping () -> Void) {
        PersistenceService.backgroundContext.perform {
            self.filterData()
            
            DispatchQueue.main.async {
                completionHandler()
            }
        }
    }
    
    func loadData() {
        let predicate = NSPredicate(format: "lyrics != nil")
        let sortDescriptors = [NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
        
        if let data: [SongLyric] = CoreDataService.fetchData(predicate: predicate, sortDescriptors: sortDescriptors, context: PersistenceService.backgroundContext) {
            self.allSongLyrics = data
        } else {
            self.allSongLyrics = []
        }
    }
    
    private func search() {
        songLyricsBeforeFilter = []
        
        let predicates = [
            NSPredicate(format: "name BEGINSWITH[c] %@", searchText),
            NSPredicate(format: "name BEGINSWITH[cd] %@", searchText),
            NSPredicate(format: "name CONTAINS[c] %@", searchText, searchText),
            NSPredicate(format: "name CONTAINS[cd] %@", searchText, searchText)
        ]
        
        for predicate in predicates {
            songLyricsBeforeFilter.append(contentsOf: allSongLyrics.filter {
                predicate.evaluate(with: $0) && !songLyricsBeforeFilter.contains($0)
            })
        }
        
        var dataContainingId = allSongLyrics.filter {
            let numbers: [String]
            
            numbers = $0.numbers
            
            return NSPredicate(format: "ANY %@ CONTAINS[cd] %@", numbers, searchText).evaluate(with: nil) && !songLyricsBeforeFilter.contains($0)
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
        
        songLyricsBeforeFilter.append(contentsOf: dataContainingId)
        
        songLyricsBeforeFilter.append(contentsOf: allSongLyrics.filter {
            NSPredicate(format: "lyricsNoChords CONTAINS[cd] %@", searchText).evaluate(with: $0) && !songLyricsBeforeFilter.contains($0)
        })
    }
    
    private func filterData() {
        guard let dataSource = filterTagDataSource else {
            showingSongLyrics = songLyricsBeforeFilter
            return
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: dataSource.tags.enumerated().map { i, tags in
            let filteredTags = tags.enumerated().filter { j, _ in dataSource.active[i][j] }.map { $0.element }
            
            return filteredTags.count > 0 ? dataSource.predicateForSection(i, filteredTags) : NSPredicate(value: true)
        })

        showingSongLyrics = songLyricsBeforeFilter.filter { predicate.evaluate(with: $0) }
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

extension SongLyricDataSource {
    
    func allFavorite(_ indexes: [Int]) -> Bool {
        for i in indexes {
            if showingSongLyrics[i].isFavorite() == false {
                return false
            }
        }
        
        return indexes.count > 0
    }
    
    func toggleFavorite() -> Bool {
        guard let currentSongLyric = currentSongLyric else { return false }
        
        if currentSongLyric.isFavorite() {
            currentSongLyric.favoriteOrder = -1
            return false
        } else {
            currentSongLyric.favoriteOrder = Int16(UserSettings.favoriteOrderLast)
            return true
        }
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
        
        return !favorite
    }
    
    func songLyric(at index: Int) -> SongLyric {
        return showingSongLyrics[index]
    }
    
    func songLyrics(at indexes: [Int]) -> [SongLyric] {
        var songLyrics = [SongLyric]()
        
        for index in indexes {
            songLyrics.append(showingSongLyrics[index])
        }
        
        return songLyrics
    }
}

// MARK: - Active SongLyrics functions

extension SongLyricDataSource {
    
    func nextSongLyric() {
        guard let currentIndex = currentSongLyricIndex else { return }
        
        currentSongLyricIndex = currentIndex + 1
        
        if currentSongLyricIndex == showingSongLyrics.count {
            currentSongLyricIndex = 0
        }
    }
    
    func previousSongLyric() {
        guard let currentIndex = currentSongLyricIndex else { return }
        
        currentSongLyricIndex = currentIndex - 1
        
        if currentSongLyricIndex == -1 {
            currentSongLyricIndex = showingSongLyrics.count - 1
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
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    
    private func setCell(_ cell: UITableViewCell, _ songLyric: SongLyric) {
        guard let cell = cell as? SongLyricCell else { return }
        
        cell.favorite = canShowStar && songLyric.isFavorite()
        cell.name = songLyric.name
        cell.number = songLyric.id
        
        let numbers = songLyric.numbers.filter {
            idPredicate.evaluate(with: $0)
        }
        
        if numbers.count > 0 && (searchText == "" || (searchText.rangeOfCharacter(from: .decimalDigits) != nil && !songLyric.id!.contains(searchText))) {
            cell.number = numbers[0]
        } else {
            cell.number = songLyric.id
        }
    }
}
