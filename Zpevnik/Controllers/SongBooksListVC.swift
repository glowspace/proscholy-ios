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
        navigationController?.navigationBar.barTintColor = .white
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let songBookVC = SongBookVC()
        songBookVC.songBook = showingData[indexPath.row]
        navigationController?.pushViewController(songBookVC, animated: true)
    }
}
