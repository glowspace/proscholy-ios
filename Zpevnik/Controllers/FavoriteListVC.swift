//
//  FavoriteListController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class FavoriteListVC: SongLyricsListVC {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showSearchView(placeholder: "Zadejte název či číslo písně")
        
        loadData()
    }
    
    override func loadData() {
        if let data: [SongLyric] = CoreDataService.fetchData(predicate: NSPredicate(format: "favoriteOrder != -1"), sortDescriptors: [NSSortDescriptor(key: "favoriteOrder", ascending: true)], context: PersistenceService.context) {
            self.data = data
            
            showingData = data
            showData()
        }
    }
}
