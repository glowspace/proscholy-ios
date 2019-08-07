//
//  Protocols.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

protocol SongDataSource: NSManagedObject {
    func setCell(_ cell: UITableViewCell)
    
    static func registerCell(_ tableView: UITableView, forCellReuseIdentifier identifier: String)
    
    static func getPredicates(forSearchText searchText: String) -> [NSPredicate]
}

protocol SongLyricDelegate {
    func changeSongLyric(_ controller: SongLyricVC, change: Int)
}

protocol FilterDelegate {
    func updateSelected() 
}
