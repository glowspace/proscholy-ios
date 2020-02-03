//
//  PlaylistDataSource.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 28/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class PlaylistDataSource: NSObject {
    
    private let user: User
    var playlists: [Playlist]
    
    var currentIndexPath: IndexPath?
    
    init(_ user: User) {
        self.user = user
        playlists = user.playlists?.allObjects as? [Playlist] ?? []
        
        super.init()
    }
}

// MARK: - UITableViewDataSource

extension PlaylistDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (user.playlists?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell") as? MoreOptionsCell else { return UITableViewCell() }
        
        let row = indexPath.row - 1
        if row < 0 {
            cell.icon = .starFilled
            cell.title = "Písně s hvězdičkou"
            return cell
        }
        
        cell.icon = .more
        cell.title = playlists[row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.currentIndexPath = nil
        
        let movedPlaylist = playlists[sourceIndexPath.row - 1]
        playlists.remove(at: sourceIndexPath.row - 1)
        playlists.insert(movedPlaylist, at: destinationIndexPath.row - 1)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
}
