//
//  AddToPlaylistVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 26/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class AddToPlaylistVC: HalfViewController {
    
    var songLyrics: [SongLyric]!
    
    private lazy var playlistsList: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(MoreOptionsCell.self, forCellReuseIdentifier: "playlistCell")
        
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = .systemBackground
        } else {
            tableView.backgroundColor = .white
        }
        
        // disable all panning, so you can hide this view on iPad
        for recognizer in tableView.gestureRecognizers! {
            if recognizer.isEnabled && (recognizer is UIPanGestureRecognizer) {
                recognizer.isEnabled = false
            }
        }
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
    }
    
    private func setViews() {
        view.addSubview(playlistsList)
        
        playlistsList.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playlistsList.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        if UIDevice.current.userInterfaceIdiom == .phone {
            playlistsList.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            playlistsList.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        } else {
            playlistsList.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 3).isActive = true
            playlistsList.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -24).isActive = true
        }
    }
    
    private func createNewPlaylist() {
        let alert = UIAlertController(title: "Vytvořit nový playlist", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Zrušit", style: .cancel, handler: nil))

        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Název playlistu"
            textField.autocapitalizationType = .sentences
            textField.enablesReturnKeyAutomatically = true
            textField.returnKeyType = .done
        })

        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in
            if let name = alert.textFields?.first?.text {
                if let playlist = Playlist.create("0", name, user!) {
                    self.addToPlaylist(playlist)
                }
            }
        })
        okAction.isEnabled = false
        
        alert.addAction(okAction)
        
        NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: alert.textFields?[0], queue: OperationQueue.main) { (notification) -> Void in
            if let count = alert.textFields?[0].text?.count, count > 0 {
                okAction.isEnabled = true
            } else {
                okAction.isEnabled = false
            }
        }

        self.present(alert, animated: true)
    }
    
    private func addToPlaylist(_ playlist: Playlist) {
        playlistsList.reloadData()
        
        for songLyric in self.songLyrics {
            playlist.addToSongLyrics(songLyric)
            songLyric.addToPlaylists(playlist)
        }
        
        self.dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension AddToPlaylistVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = user?.playlists?.count {
            return count + 1
        }
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "playlistCell", for: indexPath) as? MoreOptionsCell else { return UITableViewCell() }
        
        if indexPath.row == 0 {
            cell.icon = .add
            cell.title = "Nový playlist"
        } else if let playlists = user?.playlists?.allObjects as? [Playlist] {
            cell.icon = .rightArrow
            cell.title = playlists[indexPath.row - 1].name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            createNewPlaylist()
            return
        }
        
        if let playlists = user?.playlists?.allObjects as? [Playlist] {
            addToPlaylist(playlists[indexPath.row - 1])
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableViewHeader("Přidat do seznamu písní", .gray2)
    }
}
