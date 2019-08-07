//
//  LaunchViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class LaunchVC: UIViewController {
    
    let progressInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textAlignment = .center
        
        return label
    }()
    
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        view.backgroundColor = Constants.getMiddleColor() ?? .white
        
        view.addSubview(loadingIndicator)
        view.addSubview(progressInfoLabel)
        
        let views = [
            "loadingIndicator": loadingIndicator,
            "progressInfoLabel": progressInfoLabel
        ]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[loadingIndicator]-|", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[progressInfoLabel]-|", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[loadingIndicator]-[progressInfoLabel]-|", metrics: nil, views: views))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        
        if let lastUpdate = defaults.string(forKey: "lastUpdate") {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            let date = Date()
            let last = dateFormatter.date(from: lastUpdate)!
            if date.timeIntervalSince(last) > Constants.songsUpdateInterval {
                updateSongLyrics()
            } else {
                navigationController?.present(TabBarController(), animated: false)
            }
        } else {
            updateSongLyrics()
        }
    }
    
    private func updateSongLyrics() {
        progressInfoLabel.text = "Příprava písní"
        loadingIndicator.startAnimating()
        
        DownloadService.updateSongs({ progressInfo in
            DispatchQueue.main.async {
                self.progressInfoLabel.text = progressInfo
            }
        }) {
            DispatchQueue.main.async {
                self.loadingIndicator.stopAnimating()
                self.navigationController?.present(TabBarController(), animated: false)
            }
        }
    }
}
