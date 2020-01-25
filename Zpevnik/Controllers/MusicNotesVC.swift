//
//  MusicNotesVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit
import WebKit

class MusicNotesVC: ViewController {
    
    var songLyric: SongLyric!
    
    private lazy var musicNotesView: WKWebView = {
        let view = WKWebView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        if let url = songLyric.musicalNotesURL() {
            view.load(URLRequest(url: url))
        }
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Noty"
        
        setViews()
    }
    
    private func setViews() {
        view.addSubview(musicNotesView)
        
        musicNotesView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        musicNotesView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        musicNotesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        musicNotesView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        view.layoutIfNeeded()
    }
}
