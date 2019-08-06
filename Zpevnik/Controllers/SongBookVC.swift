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
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backButtonTapped)))
        
        view.backgroundColor = .clear
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchView.layer.borderWidth = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setTitle(songBook.name)
        navigationController?.navigationBar.barTintColor = .from(hex: songBook.color)
        navigationItem.setRightBarButton(searchBarButton, animated: true)
        
        navigationController?.navigationBar.addSubview(emptyBackButtonView)
        
        navigationController?.navigationBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[emptyBackButtonView(==44)]", metrics: nil, views: ["emptyBackButtonView": emptyBackButtonView]))
        navigationController?.navigationBar.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[emptyBackButtonView(==44)]", metrics: nil, views: ["emptyBackButtonView": emptyBackButtonView]))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchView.searchField.text = ""
        updateData(sender: searchView.searchField)
        searchView.searchField.resignFirstResponder()
        navigationItem.titleView = nil
        navigationItem.setRightBarButton(searchBarButton, animated: true)
        
        emptyBackButtonView.removeFromSuperview()
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
        
        showData()
    }
    
    // MARK: - Handlers
    
    @objc func backButtonTapped() {
        if searchView.searchField.isEditing {
            searchView.searchField.text = ""
            updateData(sender: searchView.searchField)
            searchView.searchField.resignFirstResponder()
            setTitle(songBook.name)
            navigationItem.setRightBarButton(searchBarButton, animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func showSearch() {
        navigationItem.setRightBarButton(nil, animated: true)
        showSearchView(placeholder: "Zadejte název či číslo písně")
        searchView.searchField.becomeFirstResponder()
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as! SongLyricCell
        
        let songLyric = showingData[indexPath.row]
        
        cell.nameLabel.text = songLyric.name
        if let songBookRecords = songLyric.songBookRecords?.allObjects as? [SongBookRecord] {
            for songBookRecord in songBookRecords {
                if songBookRecord.songBook == songBook {
                    cell.numberLabel.text = songBook.shortcut! + songBookRecord.number!
                    break
                }
            }
        }
        
        return cell
    }
}
