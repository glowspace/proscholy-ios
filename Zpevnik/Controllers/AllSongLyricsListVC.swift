//
//  AllSongLyricsListVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 03/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class AllSongLyricsListVC: SongLyricsListVC {
    
    lazy var starButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(named: "starIcon"), style: .plain, target: self, action: #selector(starSelected))
        
        return button
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
    
    private func updateSelectionTitle(_ selectedCount: Int) {
        if selectedCount == 1 {
            navigationItem.title = "1 píseň"
        } else if selectedCount < 5 {
            navigationItem.title = String(selectedCount) + " písně"
        } else {
            navigationItem.title = String(selectedCount) + " písní"
        }
    }
    
    // MARK: - Handlers
    
    @objc func activateSongSelection(_ recognizer: UILongPressGestureRecognizer) {
        if !tableView.isEditing && recognizer.state == .began {
            let touchPoint = recognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                tableView.setEditing(true, animated: true)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                
                navigationItem.titleView = nil
                navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(disableSelection))
                let selectAllButton = UIBarButtonItem(image: UIImage(named: "selectAllIcon"), style: .plain, target: self, action: #selector(selectAllLyrics))
                selectAllButton.isEnabled = showingData.count <= 50
                if showingData[indexPath.row].favoriteOrder > -1 {
                    starButton.image = UIImage(named: "starIconFilled")
                }
                navigationItem.setRightBarButtonItems([selectAllButton, starButton], animated: true)
                navigationItem.title = "1 píseň"
                
                self.tabBarController?.tabBar.isHidden = true
            }
        }
    }
    
    @objc func disableSelection() {
        tableView.setEditing(false, animated: true)
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.setRightBarButtonItems(nil, animated: true)
        navigationItem.title = nil
        
        showSearchView(placeholder: "Zadejte název či číslo písně")
        
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @objc func selectAllLyrics() {
        for i in 0..<showingData.count {
            tableView.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .none)
        }
    }
    
    @objc func starSelected() {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        let defaults = UserDefaults.standard
        
        if shouldAddToFavorites() {
            var favoriteOrder = defaults.integer(forKey: "favoriteOrder")
            
            for indexPath in indexPaths {
                if showingData[indexPath.row].favoriteOrder == -1 {
                    showingData[indexPath.row].favoriteOrder = Int16(favoriteOrder)
                    favoriteOrder += 1
                }
            }
            
            starButton.image = UIImage(named: "starIconFilled")
            
            defaults.set(favoriteOrder, forKey: "favoriteOrder")
        } else {
            for indexPath in indexPaths {
                showingData[indexPath.row].favoriteOrder = -1
            }
            
            starButton.image = UIImage(named: "starIcon")
        }
        
        PersistenceService.saveContext()
    }
    
    private func shouldAddToFavorites() -> Bool {
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return true }
        
        for indexPath in indexPaths {
            if showingData[indexPath.row].favoriteOrder == -1 {
                return true
            }
        }
        
        return false
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
            navigationItem.title = "Nic nevybráno"
        }
        
        starButton.image = shouldAddToFavorites() ? UIImage(named: "starIcon"): UIImage(named: "starIconFilled")
    }
}
