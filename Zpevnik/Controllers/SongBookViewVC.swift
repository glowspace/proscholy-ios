//
//  SongBookVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongBookViewVC: SongListViewVC {
    
    var songBook: SongBook!
    
    private lazy var searchButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: .search, style: .plain, target: self, action: #selector(toggleSearch))
        
        barButtonItem.tintColor = .icon
        
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = SongBooksSongLyricDataSource(songBook)
        dataSource.filterTagDataSource = filterTagDataSource
        
        setViews()
        
        dataSource.showAll {
            self.songList.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar(isSearching)
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
    
    private func setNavigationBar(_ showSearchView: Bool) {
        if showSearchView {
            navigationItem.title = ""
            navigationItem.setRightBarButtonItems(nil, animated: false)
            navigationItem.setHidesBackButton(true, animated: false)
            
            navigationController?.navigationBar.addSubview(searchView)
            
            navigationController?.navigationBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[searchView]-8-|", metrics: nil, views: ["searchView": searchView]))
            navigationController?.navigationBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[searchView(==44)]", metrics: nil, views: ["searchView": searchView]))
        } else {
            navigationItem.title = songBook.name
            navigationItem.setRightBarButtonItems([searchButton], animated: false)
            navigationItem.setHidesBackButton(false, animated: false)
            
            searchView.removeFromSuperview()
        }
    }
}

// MARK: - Handlers

extension SongBookViewVC {
    
    @objc override func toggleSearch() {
        setNavigationBar(!isSearching)
        
        super.toggleSearch()
    }
}
