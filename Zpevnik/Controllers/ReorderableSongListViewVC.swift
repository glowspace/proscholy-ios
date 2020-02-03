//
//  ReorderableSongList.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 29/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class ReorderableSongListViewVC: SongListViewVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        songList.isEditing = true
        songList.allowsSelectionDuringEditing = true
    }
}

// MARK: - UITableViewDelegate

extension ReorderableSongListViewVC {
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }
}


