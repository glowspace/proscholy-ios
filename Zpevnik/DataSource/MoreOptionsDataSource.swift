//
//  MoreOptionsDataSource.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 21/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

enum OptionsType {
    case songLyric, songList, songListArchived, settings
}

class OptionsDataSource: NSObject, UITableViewDataSource {
    
    let titles: [String]
    let icons: [UIImage?]
    
    init(_ optionsType: OptionsType) {
        switch(optionsType) {
        case .songLyric:
            titles = ["Přidat do seznamu", "Zpěvníky", "Noty", "Sdílet", "Otevřit na webu", "Nahlásit"]
            icons = [.addPlaylist, .songBook, .musicNotes, .share, .web, .warning]
        case .songList:
            titles = [""]
            icons = []
        case .songListArchived:
            titles = [""]
            icons = []
        case .settings:
            titles = ["Nastavení", "Webová verze", "Zpětná vazba", "Přidat píseň", "O projektu", "O aplikaci"]
            icons = [.settings, .web, .feedback, .add, .aboutProject, .aboutApp]
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
