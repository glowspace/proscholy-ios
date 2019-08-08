//
//  FavoriteListController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class FavoriteListVC: SongLyricsListVC {
    
    let noFavoritesView: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Nejsou vybrané žádné oblíbené písně."
        label.textAlignment = .center
        
        label.numberOfLines = 0
        
        view.addSubview(label)
        
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))

        return view
    }()
    
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
            
            updateData(sender: searchView.searchField)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = super.tableView(tableView, numberOfRowsInSection: section)
        
        if numberOfRows == 0 {
            if let label = noFavoritesView.subviews[0] as? UILabel {
                label.darkMode = UserSettings.darkMode
            }
            tableView.backgroundView = noFavoritesView
        } else {
            tableView.backgroundView = nil
        }
        
        return numberOfRows
    }
}
