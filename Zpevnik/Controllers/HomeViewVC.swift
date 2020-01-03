//
//  HomeViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class HomeViewVC: SearchViewVC {
    
    private let dataSource = SongLyricDataSource("lastSearchedHome")
    
    private var tableViewTopToSearchView: NSLayoutConstraint?
    private var tableViewTopToView: NSLayoutConstraint?
    
    private lazy var starButton: UIBarButtonItem = { createBarButtonItem(image: .star, selector: #selector(starSelected)) }()
    private lazy var addToListButton: UIBarButtonItem = { createBarButtonItem(image: .add, selector: #selector(addToList)) }()
    private lazy var selectAllButton: UIBarButtonItem = { createBarButtonItem(image: .selectAll, selector: #selector(selectAllLyrics)) }()
    
    private lazy var cancelButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(disableSelection))
        barButtonItem.tintColor = .blue
        
        return barButtonItem
    }()
    
    private lazy var songList: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        tableView.register(SongLyricCell.self, forCellReuseIdentifier: "songLyricCell")
        
        tableView.separatorStyle = .none
        
        if #available(iOS 13, *) {
            tableView.backgroundColor = .systemBackground
        }
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(activateSongSelection(_: )))
        tableView.addGestureRecognizer(longPress)
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.showAll {
            self.songList.reloadData()
        }
        
        navigationItem.setLeftBarButton(cancelButton, animated: false)
        navigationItem.setRightBarButtonItems([selectAllButton, addToListButton, starButton], animated: false)
        
        setViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let index = songList.indexPathForSelectedRow {
            songList.deselectRow(at: index, animated: animated)
        }
    }
    
    private func setViews() {
        setPlaceholder("Zadejte slovo nebo číslo")
        searchView.searchField.addTarget(self, action: #selector(search(sender:)), for: .editingChanged)
        
        view.addSubview(songList)
        
        tableViewTopToSearchView = songList.topAnchor.constraint(equalToSystemSpacingBelow: searchView.bottomAnchor, multiplier: 1)
        tableViewTopToView = songList.topAnchor.constraint(equalTo: view.topAnchor)
        
        tableViewTopToSearchView?.isActive = true
        songList.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        songList.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        songList.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func createBarButtonItem(image: UIImage?, selector: Selector) -> UIBarButtonItem {
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: selector)
        barButtonItem.tintColor = .blue
        
        return barButtonItem
    }
}

// MARK: - UITableViewDelegate

extension HomeViewVC: UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchView.searchField.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if dataSource.searchText.count > 0 {
            return .leastNormalMagnitude
        }

        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if dataSource.searchText.count > 0 {
            return nil
        }
        
        if isSearching {
            if #available(iOS 13, *) {
                return TableViewHeader("Nedávno vyhledané", .secondaryLabel)
            }
            
            return TableViewHeader("Nedávno vyhledané", .gray)
        }
        
        return TableViewHeader("Abecední seznam všech písní", .blue)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            updateSelection(tableView.indexPathsForSelectedRows?.count ?? 0)
            return
        }
        
        guard let songLyric = dataSource.songLyric(at: indexPath.row) else { return }
        let songLyricVC = SongLyricVC()
    
        if isSearching {
            let defaults = UserDefaults.standard
            
            var lastSearched = defaults.array(forKey: "lastSearchedHome") as? [String] ?? []
            
            if let index = lastSearched.firstIndex(of: songLyric.id!) {
                lastSearched.remove(at: index)
            }
            
            lastSearched.append(songLyric.id!)
            
            defaults.set(lastSearched, forKey: "lastSearchedHome")
            
            if dataSource.searchText.count == 0 {
                dataSource.search(nil) {
                    self.songList.reloadData()
                }
            }
        }
        
        songLyricVC.songLyric = songLyric
        
        navigationController?.pushViewController(songLyricVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        updateSelection(tableView.indexPathsForSelectedRows?.count ?? 0)
    }
}

// MARK: - UITextFieldDelegate

extension HomeViewVC {
    
    @objc override func toggleSearch() {
        super.toggleSearch()
        
        if !isSearching {
            dataSource.showAll {
                self.songList.reloadData()
            }
        }
    }
    
    @objc func search(sender: UITextField) {
        dataSource.search(sender.text) {
            self.songList.reloadData()
            
            if self.songList.visibleCells.count > 0 {
                self.songList.showsVerticalScrollIndicator = false
                self.songList.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.songList.showsVerticalScrollIndicator = true
            }
        }
    }
    
    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        
        if dataSource.searchText.count == 0 {
            dataSource.search(nil) {
                self.songList.reloadData()
                
                if self.songList.visibleCells.count > 0 {
                    self.songList.showsVerticalScrollIndicator = false
                    self.songList.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    self.songList.showsVerticalScrollIndicator = true
                }
            }
        }
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
    
    @objc func starSelected() {
        guard let indexPaths = songList.indexPathsForSelectedRows else { return }
        
        starButton.image = dataSource.toggleFavorites(indexPaths.map { $0.row} ) ? .starFilled : .star
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

        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        searchView.updateBorder()
    }
}
