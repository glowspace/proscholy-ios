//
//  SongBookVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongBookVC: SongLyricsListVC {
    
    lazy var searchBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "searchIcon"), style: .plain, target: self, action: #selector(showSearch))
        
        return barButtonItem
    }()
    
    lazy var emptyBackButtonView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .clear
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonTapped)))
        
        return view
    }()
    
    var songBook: SongBook!
    
    var searching = false
    
    override func viewDidLoad() {
        dataSource = SongLyricDataSource(songBook: songBook)
        
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.addSubview(emptyBackButtonView)
        navigationController?.navigationBar.barTintColor = .from(hex: songBook.color)
        navigationController?.navigationBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[emptyBackButtonView(==44)]", metrics: nil, views: ["emptyBackButtonView": emptyBackButtonView]))
        navigationController?.navigationBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[emptyBackButtonView(==44)]", metrics: nil, views: ["emptyBackButtonView": emptyBackButtonView]))
        
        if !searching {
            setTitle(songBook.name)
            navigationItem.setRightBarButton(searchBarButton, animated: true)
        } else {
            showSearchView(placeholder: "Zadejte název či číslo písně")
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        emptyBackButtonView.removeFromSuperview()
        searchView.searchField.resignFirstResponder()
    }
    
    // MARK: - Handlers
    
    @objc func backButtonTapped() {
        if navigationItem.rightBarButtonItem == nil {
            searching = false
            searchView.searchField.text = ""
            searchView.searchField.resignFirstResponder()
            dataSource.updateData()
            
            setTitle(songBook.name)
            navigationItem.setRightBarButton(searchBarButton, animated: true)
            
            filterVC.clearFilters()
            if showingFilter {
                toggleFilters()
            }
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func showSearch() {
        navigationItem.setRightBarButton(nil, animated: true)
        
        searching = true
        showSearchView(placeholder: "Zadejte název či číslo písně")
        searchView.searchField.becomeFirstResponder()
    }
}
