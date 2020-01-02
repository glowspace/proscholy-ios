//
//  HomeViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class HomeViewVC: ViewController {
    
    private let dataSource = SongLyricDataSource()
    
    private lazy var searchView: SearchView = {
        let searchIconView = UIImageView(image: UIImage(named: "searchIcon"))
        if #available(iOS 13, *) {
            searchIconView.tintColor = .systemGray2
        }
        
        let filterIconView = UIImageView(image: UIImage(named: "filterIcon"))
        if #available(iOS 13, *) {
            filterIconView.tintColor = .systemGray2
        }
        
        let searchView = SearchView(leadingView: searchIconView, trailingView: filterIconView)
        
        searchView.searchField.placeholder = "Zadejte slovo nebo číslo"
        searchView.searchField.addTarget(self, action: #selector(search(sender:)), for: .editingChanged)
        
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
        
        dataSource.updateData {
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
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchView]-|", metrics: nil, views: views))
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

        return TableViewHeader("Abecední seznam všech písní", .blue)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let songLyricVC = SongLyricVC()
        
        songLyricVC.songLyric = dataSource.showingSongLyrics[indexPath.row]
        
        navigationController?.pushViewController(songLyricVC, animated: true)
    }
}

extension HomeViewVC {
    
    @objc func search(sender: UITextField) {
        self.dataSource.updateData(sender.text) {
            self.tableView.reloadData()
            
            if self.tableView.visibleCells.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
            }
        }
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
