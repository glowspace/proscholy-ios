//
//  MoreOptionsDataSource.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 21/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

enum OptionsType {
    case songLyric, songList, songListArchived
}

class OptionsDataSource: NSObject, UITableViewDataSource {
    
    let titles: [String]
    let icons: [UIImage?]
    
    init(_ optionsType: OptionsType) {
        switch(optionsType) {
        case .songLyric:
            titles = ["Přidat do seznamu", "Zpěvníky", "Noty", "Sdílet", "Otevřit na webu", "Nahlásit"]
            icons = [.add, .songBook, .musicNotes, .share, .web, .warning]
        case .songList:
            titles = [""]
            icons = []
        case .songListArchived:
            titles = [""]
            icons = []
        }
    }
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "moreOptionsCell") as? MoreOptionsCell else { return UITableViewCell() }
        
        cell.icon = icons[indexPath.row]
        cell.title = titles[indexPath.row]
        
        return cell
    }
}
