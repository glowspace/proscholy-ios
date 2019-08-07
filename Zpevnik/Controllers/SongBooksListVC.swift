//
//  SongBookListController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongBooksListVC: ListVC<SongBook> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showSearchView(placeholder: "Zadejte název či zkratku zpěvníku")
//        navigationController?.navigationBar.barTintColor = .white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func loadData() {
        if let data: [SongBook] = CoreDataService.fetchData(predicate: NSPredicate(format: "isPrivate == false"), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], context: PersistenceService.context) {
            self.data = data
            
            updateData(sender: searchView.searchField)
        }
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return super.tableView(tableView, numberOfRowsInSection: section) + 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            navigationController?.pushViewController(AllSongLyricsListVC(), animated: true)
        } else {
            let songBookVC = SongBookVC()
            songBookVC.songBook = showingData[indexPath.row - 1]
            navigationController?.pushViewController(songBookVC, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row > 0 {
            var indexPath = indexPath
            indexPath.row -= 1
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId") as! SongBookCell
        
        cell.shortcutLabel.text = "A-Z"
        cell.nameLabel.text = "Rejstřík"
        cell.shortcutBackgroundColor = .from(hex: nil)
        
        return cell
    }
}
