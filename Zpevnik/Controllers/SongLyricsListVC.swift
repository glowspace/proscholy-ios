//
//  SongLyricsListVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 02/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongLyricsListVC: ListVC<SongLyric> {
    
    var currentSongLyricIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadData() {
        if let data = CoreDataService.fetchData(entityName: entityName, predicate: NSPredicate(format: "lyrics != nil"), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], context: PersistenceService.context) as? [SongLyric] {
            self.data = data
            
            updateData(sender: searchView.searchField)
        }
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        currentSongLyricIndex = indexPath.row
        
        let songLyricVC = SongLyricVC()
        songLyricVC.delegate = self
        songLyricVC.songLyric = showingData[indexPath.row]
        navigationController?.pushViewController(songLyricVC, animated: true)
    }
}

extension SongLyricsListVC: SongLyricDelegate {
    
    func changeSongLyric(_ controller: SongLyricVC, change: Int) {
        if var currentSongLyricIndex = currentSongLyricIndex {
            currentSongLyricIndex = (currentSongLyricIndex + change) % showingData.count
            if currentSongLyricIndex < 0 {
                currentSongLyricIndex = showingData.count - 1
            }
            controller.songLyric = showingData[currentSongLyricIndex]
            controller.updateSongLyrics()
            self.currentSongLyricIndex = currentSongLyricIndex
        }
    }
}
