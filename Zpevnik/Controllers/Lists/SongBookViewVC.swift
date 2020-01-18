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
        let barButtonItem = UIBarButtonItem(image: .search, style: .plain, target: self, action: #selector(showSearch))
        
        if #available(iOS 13, *) {
            barButtonItem.tintColor = .systemGray2
        }
        
        return barButtonItem
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = SongBooksSongLyricDataSource(songBook)
        dataSource.filterTagDataSource = filterTagDataSource
        
        dataSource.showAll {
            self.songList.reloadData()
        }
        
        navigationItem.title = songBook.name
        navigationItem.setRightBarButton(searchButton, animated: true)
        
        setViews()
    }
    
    private func setViews() {
        searchView.trailingButton?.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        setPlaceholder("Zadejte slovo nebo číslo")
        
        view.addSubview(songList)
        
        songList.topAnchor.constraint(equalToSystemSpacingBelow: searchView.bottomAnchor, multiplier: 1).isActive = true
        songList.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        songList.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        songList.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}

extension SongBookViewVC {
    
    @objc func showSearch() {
        
    }
}
