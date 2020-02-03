//
//  TranslationsViewVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 22/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class TranslationsViewVC: ViewController {
    
    var delegate: TranslationDelegate?
    
    var songLyric: SongLyric! {
        didSet {
            guard let lyrics = songLyric.song?.songLyrics?.allObjects as? [SongLyric] else { return }
            
            for lyric in lyrics {
                switch(SongLyricType(rawValue: Int(lyric.type))) {
                case .original:
                    original = lyric
                case .authorizedTranslation:
                    authorizedTranslations.append(lyric)
                case .translation:
                    translations.append(lyric)
                default:
                    break
                }
            }
        }
    }
    
    private var original: SongLyric!
    private var authorizedTranslations = [SongLyric]()
    private var translations = [SongLyric]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(SongLyricCell.self, forCellReuseIdentifier: "songLyricCell")
        
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        
        if #available(iOS 13, *) {
            tableView.backgroundColor = .systemBackground
        }
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        
        navigationItem.title = "Překlady písně"
    }
    
    private func setViews() {
        view.addSubview(tableView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[tableView]-|", metrics: nil, views: ["tableView": tableView]))
    }
}

extension TranslationsViewVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? (original == nil ? 0 : 1) : (section == 1 ? authorizedTranslations.count : translations.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "songLyricCell") as? SongLyricCell else { return UITableViewCell() }
        
        let songLyric: SongLyric
        
        if indexPath.section == 0 {
            songLyric = original
        } else if indexPath.section == 1 {
            songLyric = authorizedTranslations[indexPath.row]
        } else {
            songLyric = translations[indexPath.row]
        }
        
        cell.name = songLyric.name
        cell.number = songLyric.id
        cell.verticalSpacing = 6
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 8
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 && original != nil {
            return tableView.sectionHeaderHeight
        } else if section == 1 && authorizedTranslations.count > 0 {
            return tableView.sectionHeaderHeight
        } else if section == 2 && translations.count > 0 {
            return tableView.sectionHeaderHeight
        }

        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return original == nil ? nil : TableViewHeader("Originál", .blue)
        } else if section == 1 {
            return authorizedTranslations.count == 0 ? nil : TableViewHeader("Autorizované překlady", .yellow)
        }
        
        return translations.count == 0 ? nil : TableViewHeader("Překlady", .green)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let songLyric: SongLyric
        
        if indexPath.section == 0 {
            songLyric = original
        } else if indexPath.section == 1 {
            songLyric = authorizedTranslations[indexPath.row]
        } else {
            songLyric = translations[indexPath.row]
        }
        
        delegate?.songLyricTranslationChanged(songLyric)
    }
}
