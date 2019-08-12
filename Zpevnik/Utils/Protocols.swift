//
//  Protocols.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

protocol DataSource {
    func setCell(_ cell: UITableViewCell, _ object: NSManagedObject)
    
    func registerCell(_ tableView: UITableView, forCellReuseIdentifier identifier: String)
    
    func getPredicates(forSearchText searchText: String) -> [NSPredicate]
}

protocol SongLyricDelegate {
    func changeSongLyric(_ controller: SongLyricVC, change: Int)
}

protocol FilterDelegate {
    func updateSelected() 
}

protocol FilterTag {
    var title: String { get }
    
    var elements: [FilterAble] { get }
}

protocol FilterAble {
    var name: String? { get }
    
    static var predicateFormat: String { get }
}
