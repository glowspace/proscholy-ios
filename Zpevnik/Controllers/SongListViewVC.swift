//
//  SongListViewVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 09/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongListViewVC: AllSongListViewVC {
    
    private lazy var searchButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: .search, style: .plain, target: self, action: #selector(toggleSearch))
        
        barButtonItem.tintColor = .icon
        
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar(isSearching)
        
        dataSource.loadData()
        dataSource.showAll {
            self.songList.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setNavigationBar(false)
    }
    
    private func setViews() {
        searchView.leadingButton?.setImage(.back, for: .normal)
        searchView.trailingButton?.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        
        setPlaceholder("Zadejte slovo nebo číslo")
        
        view.addSubview(songList)
        
        songList.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 1).isActive = true
        songList.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        songList.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        songList.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    internal func setNavigationBar(_ showSearchView: Bool) {
        if showSearchView {
            navigationItem.title = ""
            navigationItem.setRightBarButtonItems(nil, animated: true)
            navigationItem.setHidesBackButton(true, animated: true)
            
            navigationController?.navigationBar.addSubview(searchView)
            
            navigationController?.navigationBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[searchView]-8-|", metrics: nil, views: ["searchView": searchView]))
            navigationController?.navigationBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[searchView(==44)]", metrics: nil, views: ["searchView": searchView]))
            
            searchView.searchField.updateFontSize()
            
            searchView.alpha = 0
            searchView.transform = CGAffineTransform.identity.scaledBy(x: 0.01, y: 0.01)
            
            UIView.animate(withDuration: 0.3) {
                self.searchView.alpha = 1
                self.searchView.transform = .identity
            }
        } else {
            navigationItem.title = dataSource.title
            navigationItem.setRightBarButtonItems([searchButton], animated: true)
            navigationItem.setHidesBackButton(false, animated: true)
            
            UIView.animate(withDuration: 0.3, animations: {
                self.searchView.alpha = 0
                self.searchView.transform = CGAffineTransform.identity.scaledBy(x: 0.01, y: 0.01)
            }) { _ in
                self.searchView.removeFromSuperview()
            }
        }
    }
}

// MARK: - Handlers

extension SongListViewVC {
    
    @objc override func toggleSearch() {
        setNavigationBar(!isSearching)
        
        super.toggleSearch()
    }
}
