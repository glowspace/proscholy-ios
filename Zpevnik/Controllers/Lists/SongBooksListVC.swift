//
//  SongBookListController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongBooksListVC: ListVC<SongBookDataSource> {
    
    lazy var allSongLyricsVC: AllSongLyricsListVC = {
        let vc = AllSongLyricsListVC()
        
        return vc
    }()
    
    override func viewDidLoad() {
        dataSource = SongBookDataSource()
        super.viewDidLoad()
        
        searchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[searchField]-|", metrics: nil, views: ["searchField": searchView.searchField]))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        allSongLyricsVC.searchView.searchField.text = ""
        
        showSearchView(placeholder: "Zadejte název či zkratku zpěvníku")
        
        navigationController?.navigationBar.barTintColor = Constants.getMiddleColor()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // needed to correctly update placeholder font size in next VC
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section) + 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            navigationController?.pushViewController(allSongLyricsVC, animated: true)
        } else {
            let songBookVC = SongBookVC()
            songBookVC.songBook = dataSource.showingData[indexPath.row - 1]
            navigationController?.pushViewController(songBookVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > 0 {
            return super.tableView(tableView, cellForRowAt: IndexPath(row: indexPath.row - 1, section: indexPath.section))
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") as! SongBookCell
        
        cell.shortcutLabel.text = "A-Z"
        cell.nameLabel.text = "Rejstřík"
        cell.shortcutBackgroundColor = .from(hex: nil)
        
        return cell
    }
}
