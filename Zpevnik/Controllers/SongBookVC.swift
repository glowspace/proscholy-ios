//
//  SongBookVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongBookVC: SongLyricsListVC {
    
    var songBook: SongBook!
    
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
    
    var searching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.songBook = songBook
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
    
    override func loadData() {
        if let records = songBook.records?.allObjects as? [SongBookRecord] {
            self.data = records.map {
                $0.songLyric!
            }
        }
        self.data = self.data.filter {
            $0.lyrics != nil
        }
        
        self.data.sort { (first, second) in
            var firstNumber = -1
            var secondNumber = -1
            var firstMore = ""
            var secondMore = ""
            if let songBookRecords = first.songBookRecords?.allObjects as? [SongBookRecord] {
                for songBookRecord in songBookRecords {
                    if songBookRecord.songBook == songBook {
                        firstNumber = Int(songBookRecord.number!.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))!
                        firstMore = songBookRecord.number!.replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression)
                        break
                    }
                }
            }
            if let songBookRecords = second.songBookRecords?.allObjects as? [SongBookRecord] {
                for songBookRecord in songBookRecords {
                    if songBookRecord.songBook == songBook {
                        secondNumber = Int(songBookRecord.number!.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression))!
                        secondMore = songBookRecord.number!.replacingOccurrences(of: "[0-9]", with: "", options: .regularExpression)
                        break
                    }
                }
            }
            
            if firstNumber == secondNumber {
                return firstMore < secondMore
            }
            return firstNumber < secondNumber
        }
        
        dataSource.showingData = data
        showData()
    }
    
    override func showData() {
        if let searchText = searchView.searchField.text, searchText.count > 0 {
            dataSource.showingData = dataSource.showingData.filter {
                let numbers = $0.numbers.filter {
                    $0.contains(songBook.shortcut!)
                }
                return NSPredicate(format: "ANY %@ CONTAINS[cd] %@", numbers, searchText).evaluate(with: nil)
            }
        }
        
        super.showData()
    }
    
    // MARK: - Handlers
    
    @objc func backButtonTapped() {
        if navigationItem.rightBarButtonItem == nil {
            searching = false
            searchView.searchField.text = ""
            searchView.searchField.resignFirstResponder()
            updateData(sender: searchView.searchField)
            
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
