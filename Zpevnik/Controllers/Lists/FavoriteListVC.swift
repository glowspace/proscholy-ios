//
//  FavoriteListController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class FavoriteListVC: SongLyricsListVC {
    
    var realIndexPath: IndexPath?
    
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
        
        tableView.allowsSelectionDuringEditing = true
        tableView.setEditing(true, animated: true)
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showSearchView(placeholder: "Zadejte název či číslo písně")
        
        dataSource = SongLyricDataSource(favorite: true)
        
        tableView.reloadData()
    }
    
    // MARK: - Data Handlers
    
    @objc override func updateData(sender: UITextField) {
        super.updateData(sender: sender)
        
        if sender.text?.count ?? 0 > 0 {
            tableView.setEditing(false, animated: true)
        } else {
            tableView.setEditing(true, animated: true)
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
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        realIndexPath = nil
    }
    
    override func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        let sourceLyric = dataSource.showingData[realIndexPath?.row ?? sourceIndexPath.row]
        let destinationLyric = dataSource.showingData[proposedDestinationIndexPath.row]
        
        let destinationFavoriteOrder = destinationLyric.favoriteOrder
        destinationLyric.favoriteOrder = sourceLyric.favoriteOrder
        sourceLyric.favoriteOrder = destinationFavoriteOrder
        
        dataSource.showingData[realIndexPath?.row ?? sourceIndexPath.row] = destinationLyric
        dataSource.showingData[proposedDestinationIndexPath.row] = sourceLyric
        
        realIndexPath = proposedDestinationIndexPath
        
        return proposedDestinationIndexPath
    }
}
