//
//  SongBookVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongBookViewVC: SearchViewVC {
    
    var songBook: SongBook!
    
    private lazy var dataSource: SongBooksSongLyricDataSource = { return SongBooksSongLyricDataSource(songBook) }()
    
    private var tableViewTopToSearchView: NSLayoutConstraint?
    private var tableViewTopToView: NSLayoutConstraint?
    
//    private lazy var starButton: UIBarButtonItem = { createBarButtonItem(image: .star, selector: #selector(starSelected)) }()
//    private lazy var addToListButton: UIBarButtonItem = { createBarButtonItem(image: .add, selector: #selector(addToList)) }()
//    private lazy var selectAllButton: UIBarButtonItem = { createBarButtonItem(image: .selectAll, selector: #selector(selectAllLyrics)) }()
//
//    private lazy var cancelButton: UIBarButtonItem = {
//        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(disableSelection))
//        barButtonItem.tintColor = .blue
//
//        return barButtonItem
//    }()
    
    private lazy var songList: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = dataSource
//        tableView.delegate = self
        
        tableView.register(SongLyricCell.self, forCellReuseIdentifier: "songLyricCell")
        
        tableView.separatorStyle = .none
        
        if #available(iOS 13, *) {
            tableView.backgroundColor = .systemBackground
        }
        
        tableView.allowsMultipleSelectionDuringEditing = true
        
//        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(activateSongSelection(_: )))
//        tableView.addGestureRecognizer(longPress)
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.showAll {
            self.songList.reloadData()
        }
        
//        navigationItem.setLeftBarButton(cancelButton, animated: false)
//        navigationItem.setRightBarButtonItems([selectAllButton, addToListButton, starButton], animated: false)
        
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
//        searchView.searchField.addTarget(self, action: #selector(search(sender:)), for: .editingChanged)
        
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

//class SongBookVC: SongLyricsListVC {
    
//    lazy var searchBarButton: UIBarButtonItem = {
//        let barButtonItem = UIBarButtonItem(image: UIImage(named: "searchIcon"), style: .plain, target: self, action: #selector(showSearch))
//        
//        return barButtonItem
//    }()
//    
//    lazy var emptyBackButtonView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.backgroundColor = .clear
//        
//        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonTapped)))
//        
//        return view
//    }()
//    
//    var songBook: SongBook!
//    
//    var searching = false
//    
//    override func viewDidLoad() {
//        dataSource = SongLyricDataSource_(songBook: songBook)
//        
//        super.viewDidLoad()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        navigationController?.navigationBar.addSubview(emptyBackButtonView)
//        navigationController?.navigationBar.barTintColor = .from(hex: songBook.color)
//        navigationController?.navigationBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[emptyBackButtonView(==44)]", metrics: nil, views: ["emptyBackButtonView": emptyBackButtonView]))
//        navigationController?.navigationBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[emptyBackButtonView(==44)]", metrics: nil, views: ["emptyBackButtonView": emptyBackButtonView]))
//        
//        if !searching {
//            setTitle(songBook.name)
//            navigationItem.setRightBarButton(searchBarButton, animated: true)
//        } else {
//            showSearchView(placeholder: "Zadejte název či číslo písně")
//        }
//    }
//    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        emptyBackButtonView.removeFromSuperview()
//        searchView.searchField.resignFirstResponder()
//    }
//    
//    // MARK: - Handlers
//    
//    @objc func backButtonTapped() {
//        if navigationItem.rightBarButtonItem == nil {
//            searching = false
//            searchView.searchField.text = ""
//            searchView.searchField.resignFirstResponder()
//            dataSource.updateData()
//            
//            setTitle(songBook.name)
//            navigationItem.setRightBarButton(searchBarButton, animated: true)
//            
//            filterVC.clearFilters()
//            if showingFilter {
//                toggleFilters()
//            }
//        } else {
//            navigationController?.popViewController(animated: true)
//        }
//    }
//    
//    @objc func showSearch() {
//        navigationItem.setRightBarButton(nil, animated: true)
//        
//        searching = true
//        showSearchView(placeholder: "Zadejte název či číslo písně")
//        searchView.searchField.becomeFirstResponder()
//    }
//}
