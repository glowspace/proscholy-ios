//
//  MoreOptionsDataSource.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 21/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class OptionsDataSource: NSObject, UITableViewDataSource {
    
    private var titles: [String]
    private var icons: [UIImage?]
    
    var optionsType: OptionsType? {
        didSet {
            guard let optionsType = optionsType else { return }
            
            switch(optionsType) {
            case .songLyric:
                titles = ["Přidat do seznamu", "Zpěvníky", "Noty", "Sdílet", "Otevřit na webu", "Nahlásit"]
                icons = [.addPlaylist, .songBook, .musicNotes, .share, .web, .warning]
            case .songList:
                titles = ["Přejmenovat", "Duplikovat", "Archivovat"]
                icons = [.edit, .duplicate, .archive]
            case .songListArchived:
                titles = ["Přejmenovat", "Zrušit archivaci", "Odstranit"]
                icons = [.edit, .unarchive, .bin]
            case .settings:
                titles = ["Nastavení", "Webová verze", "Zpětná vazba", "Přidat píseň", "O projektu", "O aplikaci"]
                icons = [.settings, .web, .feedback, .add, .aboutProject, .aboutApp]
            }
        }
    }
    
    override init() {
        titles = []
        icons = []
        
        super.init()
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
