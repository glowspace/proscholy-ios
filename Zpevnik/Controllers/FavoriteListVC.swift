//
//  FavoriteListController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class FavoriteListVC: SongLyricsListVC {
    
    lazy var noFavoritesView: UIView = {
        let view = UIView()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Nejsou vybrané žádné oblíbené písně."
        label.textAlignment = .center
        
        label.numberOfLines = 0
        
        view.addSubview(label)
        
        label.addConstraint(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.view.frame.width))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))

        return view
    }()
    
    override func viewDidLoad() {
        dataSource = SongLyricDataSource(favorite: true)
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showSearchView(placeholder: "Zadejte název či číslo písně")
        
        dataSource = SongLyricDataSource(favorite: true)
        
        tableView.reloadData()
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
