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
        view.addSubview(searchView)
        view.addSubview(tableView)
        
        let views = [
            "searchView": searchView,
            "tableView": tableView
        ]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[searchView]-8-|", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchView(==36)]-[tableView]-|", metrics: nil, views: views))
        
        searchView.searchField.updateFontSize()
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
        let songLyricVC = SongLyricVC()
        let songLyric = dataSource.showingSongLyrics[indexPath.row]
        
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

extension HomeViewVC {
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        searchView.updateBorder()
    }
}
