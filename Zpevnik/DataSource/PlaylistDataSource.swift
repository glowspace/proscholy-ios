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
    
    init(_ user: User) {
        self.user = user
        
        super.init()
    }
}

extension PlaylistDataSource: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (user.playlists?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell") else { return UITableViewCell() }
        
        let row = indexPath.row - 1
        if row < 0 {
            cell.textLabel?.text = "Písně s hvězdičkou"
            return cell
        }
        
        guard let playlists = user.playlists?.allObjects as? [Playlist] else { return UITableViewCell() }
        
        cell.textLabel?.text = playlists[row].name
        
        return cell
    }
}
