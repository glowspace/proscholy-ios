//
//  AllSongLyricsListVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 03/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class AllSongLyricsListVC: SongLyricsListVC {
    
    var sectionTitles: [String]?
    
    lazy var starButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "starIcon"), style: .plain, target: self, action: #selector(starSelected))
        
        return button
    }()
    
    lazy var cancelButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(disableSelection))
        
        return barButtonItem
    }()
    
    lazy var selectAllButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "selectAllIcon"), style: .plain, target: self, action: #selector(selectAllLyrics))
        
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(activateSongSelection(_: )))
        tableView.addGestureRecognizer(longPress)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showSearchView(placeholder: "Zadejte název či číslo písně")
    }
    
    @objc override func updateData(sender: UITextField) {
        super.updateData(sender: sender)
        
        dataSource.searchText = sender.text
    }
    
    // MARK: Private functions
    
    private func updateSelectionTitle(_ selectedCount: Int) {
        if selectedCount == 1 {
            setTitle("1 píseň")
        } else if selectedCount < 5 {
            setTitle(String(selectedCount) + " písně")
        } else {
            setTitle(String(selectedCount) + " písní")
        }
    }
    
    private func shouldAddToFavorites() -> Bool {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return true }
        
        for indexPath in indexPaths {
            if !dataSource.showingData[indexPath.row].isFavorite() {
                return true
            }
        }
        
        return false
    }
    
    // MARK: - Handlers
    
    @objc func activateSongSelection(_ recognizer: UILongPressGestureRecognizer) {
        if !tableView.isEditing && recognizer.state == .began {
            let touchPoint = recognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                tableView.setEditing(true, animated: true)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                
                selectAllButton.isEnabled = dataSource.showingData.count <= 50
                navigationItem.setLeftBarButton(cancelButton, animated: true)
                navigationItem.setRightBarButtonItems([selectAllButton, starButton], animated: true)
                
                navigationItem.titleView = nil
                setTitle("1 píseň")
                
                if dataSource.showingData[indexPath.row].isFavorite() {
                    starButton.image = UIImage(named: "starIconFilled")
                }
                
                self.tabBarController?.tabBar.isHidden = true
            }
        }
    }
    
    @objc func disableSelection() {
        tableView.setEditing(false, animated: true)
        
        navigationItem.setLeftBarButton(nil, animated: true)
        navigationItem.setRightBarButtonItems(nil, animated: true)
        setTitle(nil)
        
        showSearchView(placeholder: "Zadejte název či číslo písně")
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func selectAllLyrics() {
        for i in 0..<dataSource.showingData.count {
            tableView.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .none)
        }
    }
    
    @objc func starSelected() {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        let defaults = UserDefaults.standard
        
        if shouldAddToFavorites() {
            var favoriteOrder = defaults.integer(forKey: "favoriteOrder")
            
            for indexPath in indexPaths {
                if !dataSource.showingData[indexPath.row].isFavorite() {
                    dataSource.showingData[indexPath.row].favoriteOrder = Int16(favoriteOrder)
                    favoriteOrder += 1
                }
            }
            
            starButton.image = UIImage(named: "starIconFilled")
            
            defaults.set(favoriteOrder, forKey: "favoriteOrder")
        } else {
            for indexPath in indexPaths {
                dataSource.showingData[indexPath.row].favoriteOrder = -1
            }
            
            starButton.image = UIImage(named: "starIcon")
        }
        
        PersistenceService.saveContext()
    }
    
    // MARK: - UITableViewDelegete, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !tableView.isEditing {
            super.tableView(tableView, didSelectRowAt: indexPath)
        } else if let indexPaths = tableView.indexPathsForSelectedRows {
            updateSelectionTitle(indexPaths.count)
            
            starButton.image = shouldAddToFavorites() ? UIImage(named: "starIcon"): UIImage(named: "starIconFilled")
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing, let indexPaths = tableView.indexPathsForSelectedRows {
            updateSelectionTitle(indexPaths.count)
        } else {
            setTitle("Nic nevybráno")
        }
        
        starButton.image = shouldAddToFavorites() ? UIImage(named: "starIcon"): UIImage(named: "starIconFilled")
    }
}
