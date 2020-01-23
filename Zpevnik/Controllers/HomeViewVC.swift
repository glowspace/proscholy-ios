//
//  HomeViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class HomeViewVC: SongListViewVC {
    
    private var tableViewTopToSearchView: NSLayoutConstraint?
    private var tableViewTopToView: NSLayoutConstraint?
    
    private lazy var starButton: UIBarButtonItem = { createBarButtonItem(image: .star, selector: #selector(toggleFavorite)) }()
    private lazy var addToListButton: UIBarButtonItem = { createBarButtonItem(image: .add, selector: #selector(addToList)) }()
    private lazy var selectAllButton: UIBarButtonItem = { createBarButtonItem(image: .selectAll, selector: #selector(selectAllLyrics)) }()
    private lazy var cancelButton: UIBarButtonItem = { createBarButtonItem(image: .clear, selector: #selector(disableSelection)) }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = SongLyricDataSource("lastSearchedHome")
        dataSource.filterTagDataSource = filterTagDataSource
        
        dataSource.showAll {
            self.songList.reloadData()
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(activateSongSelection(_: )))
        songList.addGestureRecognizer(longPress)
        
        // add spacer to force left aligned title
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = view.frame.width
        
        navigationItem.setLeftBarButton(cancelButton, animated: false)
        navigationItem.setRightBarButtonItems([selectAllButton, addToListButton, starButton, spacer], animated: false)
        
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setViews() {
        addSearchView()
        
        searchView.trailingButton?.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        setPlaceholder("Zadejte slovo nebo číslo")
        
        view.addSubview(songList)
        
        tableViewTopToSearchView = songList.topAnchor.constraint(equalTo: searchView.bottomAnchor)
        tableViewTopToView = songList.topAnchor.constraint(equalTo: view.topAnchor)
        
        tableViewTopToSearchView?.isActive = true
        songList.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        songList.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        songList.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func addSearchView() {
        view.addSubview(searchView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[searchView]-8-|", metrics: nil, views: ["searchView": searchView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchView(==44)]", metrics: nil, views: ["searchView": searchView]))
    }
    
    private func createBarButtonItem(image: UIImage?, selector: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: selector)
        barButtonItem.tintColor = .icon
        
        return barButtonItem
    }
}

// MARK: - UITableViewDelegate

extension HomeViewVC {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if dataSource.searchText.count > 0 { //} && dataSource.activeFilters.count == 0 {
            return .leastNormalMagnitude
        }

        return tableView.sectionHeaderHeight
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if dataSource.searchText.count > 0 {
            if filterTagDataSource.activeFilters.count > 0 {
                return ActiveFilterHeaderView(dataSource: self, delegate: self)
            }
            
            return nil
        }
        
        if isSearching {
            if #available(iOS 13, *) {
                return TableViewHeader("Nedávno vyhledané", .secondaryLabel)
            }
            
            return TableViewHeader("Nedávno vyhledané", .gray)
        }
        
        if filterTagDataSource.activeFilters.count > 0 {
            return ActiveFilterHeaderView(dataSource: self, delegate: self)
        }
        
        return TableViewHeader("Abecední seznam všech písní", .blue)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateSelection(tableView.indexPathsForSelectedRows?.count ?? 0)
            return
        }
        
        super.tableView(tableView, didSelectRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateSelection(tableView.indexPathsForSelectedRows?.count ?? 0)
    }
}

// MARK: - Multiple Selection Handlers

extension HomeViewVC {
    
    private func updateSelection(_ selectedCount: Int) {
        if selectedCount == 0 {
            navigationItem.title = "0 písní"
        } else if selectedCount == 1 {
            navigationItem.title = "1 píseň"
        } else if selectedCount < 5 {
            navigationItem.title = String(format: "%d písně", selectedCount)
        } else {
            navigationItem.title = String(format: "%d písní", selectedCount)
        }
        
        starButton.isEnabled = selectedCount != 0
        addToListButton.isEnabled = selectedCount != 0
        starButton.image = dataSource.allFavorite(songList.indexPathsForSelectedRows?.map { $0.row } ?? []) ? .starFilled: .star
    }
    
    @objc func activateSongSelection(_ recognizer: UILongPressGestureRecognizer) {
        if !songList.isEditing && recognizer.state == .began {
            let touchPoint = recognizer.location(in: songList)
            if let indexPath = songList.indexPathForRow(at: touchPoint) {
                songList.setEditing(true, animated: true)
                songList.selectRow(at: indexPath, animated: true, scrollPosition: .none)

                updateSelection(1)
                
                searchView.removeFromSuperview()
                tableViewTopToSearchView?.isActive = false
                tableViewTopToView?.isActive = true

                navigationController?.setNavigationBarHidden(false, animated: false)
                tabBarController?.tabBar.isHidden = true
            }
        }
    }
    
    @objc func toggleFavorite() {
        guard let indexPaths = songList.indexPathsForSelectedRows else { return }
        
        starButton.image = dataSource.toggleFavorites(indexPaths.map { $0.row} ) ? .starFilled : .star
        
        songList.reloadRows(at: indexPaths, with: .automatic)
    }
    
    @objc func addToList() {
        
    }
    
    @objc func selectAllLyrics() {
        let selectedAll = songList.indexPathsForSelectedRows?.count == dataSource.showingCount
        
        for i in 0..<dataSource.showingCount {
            if selectedAll {
                songList.deselectRow(at: IndexPath(row: i, section: 0), animated: true)
            } else {
                songList.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .none)
            }
        }
        
        updateSelection(songList.indexPathsForSelectedRows?.count ?? 0)
    }
    
    @objc func disableSelection() {
        songList.setEditing(false, animated: true)
        
        addSearchView()
        tableViewTopToView?.isActive = false
        tableViewTopToSearchView?.isActive = true
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = false
    }
}

extension HomeViewVC {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard UIApplication.shared.applicationState == .inactive else { return }
        
        searchView.updateBorder()
    }
}
