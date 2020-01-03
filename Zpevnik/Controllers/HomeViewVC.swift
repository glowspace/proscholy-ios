//
//  HomeViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class HomeViewVC: ViewController {
    
    private let dataSource = SongLyricDataSource("lastSearchedHome")
    
    private var isSearching = false
    
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
    
    private lazy var searchView: SearchView = {        
        let searchView = SearchView(leadingButton: UIButton(type: .custom), trailingButton: UIButton(type: .custom))
        
        searchView.searchField.delegate = self
        searchView.searchField.addTarget(self, action: #selector(search(sender:)), for: .editingChanged)
        
        searchView.leadingButton?.setImage(.search, for: .normal)
        searchView.trailingButton?.setImage(.filter, for: .normal)
        
        searchView.leadingButton?.addTarget(self, action: #selector(toggleSearch), for: .touchUpInside)
        
        searchView.searchField.placeholder = "Zadejte slovo nebo číslo"
        
        return searchView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        tableView.register(SongLyricCell.self, forCellReuseIdentifier: "songCell")
        
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
        
        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
        }
        
        dataSource.showAll {
            self.tableView.reloadData()
        }
        
        navigationItem.setLeftBarButton(cancelButton, animated: false)
        navigationItem.setRightBarButtonItems([selectAllButton, addToListButton, starButton], animated: false)
        
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: animated)
        }
        
        searchView.searchField.resignFirstResponder()
    }
    
    private func setViews() {
        addSearchView()
        view.addSubview(tableView)
        
        tableViewTopToSearchView = tableView.topAnchor.constraint(equalToSystemSpacingBelow: searchView.bottomAnchor, multiplier: 1)
        tableViewTopToView = tableView.topAnchor.constraint(equalTo: view.topAnchor)
        
        tableViewTopToSearchView?.isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        searchView.searchField.updateFontSize()
    }
    
    private func addSearchView() {
        view.addSubview(searchView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[searchView]-8-|", metrics: nil, views: ["searchView": searchView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchView(==36)]", metrics: nil, views: ["searchView": searchView]))
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
                    self.tableView.reloadData()
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

extension HomeViewVC: UITextFieldDelegate {
    
    @objc func toggleSearch() {
        if isSearching {
            isSearching = false
            
            searchView.searchField.resignFirstResponder()
            searchView.searchField.text = ""
            searchView.leadingButton?.setImage(.search, for: .normal)
            
            search(sender: searchView.searchField)
            
            dataSource.showAll {
                self.tableView.reloadData()
            }
        } else {
            searchView.searchField.becomeFirstResponder()
        }
    }
    
    @objc func search(sender: UITextField) {
        dataSource.search(sender.text) {
            self.tableView.reloadData()
            
            if self.tableView.visibleCells.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchView.leadingButton?.setImage(.back, for: .normal)
        isSearching = true
        
        if dataSource.searchText.count == 0 {
            dataSource.search(nil) {
                self.tableView.reloadData()
                
                if self.tableView.visibleCells.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}

// MARK: - Multiple Selection Handlers

extension HomeViewVC {
    
    private func updateSelection(_ selectedCount: Int) {
        if selectedCount == 0 {
            setTitle("0 písní")
        } else if selectedCount == 1 {
            setTitle("1 píseň")
        } else if selectedCount < 5 {
            setTitle(String(format: "%d písně", selectedCount))
        } else {
            setTitle(String(format: "%d písní", selectedCount))
        }
        
        starButton.isEnabled = selectedCount != 0
        addToListButton.isEnabled = selectedCount != 0
        starButton.image = dataSource.allFavorite(tableView.indexPathsForSelectedRows?.map { $0.row } ?? []) ? .starFilled: .star
    }
    
    @objc func activateSongSelection(_ recognizer: UILongPressGestureRecognizer) {
        if !tableView.isEditing && recognizer.state == .began {
            let touchPoint = recognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                tableView.setEditing(true, animated: true)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)

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
        guard let indexPaths = tableView.indexPathsForSelectedRows else { return }
        
        starButton.image = dataSource.toggleFavorites(indexPaths.map { $0.row} ) ? .starFilled : .star
    }
    
    @objc func addToList() {
        
    }
    
    @objc func selectAllLyrics() {
        let selectedAll = tableView.indexPathsForSelectedRows?.count == dataSource.showingCount
        
        for i in 0..<dataSource.showingCount {
            if selectedAll {
                tableView.deselectRow(at: IndexPath(row: i, section: 0), animated: true)
            } else {
                tableView.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .none)
            }
        }
        
        updateSelection(tableView.indexPathsForSelectedRows?.count ?? 0)
    }
    
    @objc func disableSelection() {
        tableView.setEditing(false, animated: true)
        
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
