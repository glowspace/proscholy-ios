//
//  LaunchViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class LaunchVC: ViewController {
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: UserSettings.darkMode ? "backgroundDark" : "background"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: UserSettings.darkMode ? "homeScreenTitleDark" : "homeScreenTitle"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let progressInfoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textAlignment = .center
        label.text = "Příprava písní"
        
        return label
    }()
    
    let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: UserSettings.darkMode ? .white : .gray)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = true
        
        view.addSubview(backgroundImageView)
        
        view.addSubview(titleImageView)
        view.addSubview(loadingIndicator)
        view.addSubview(progressInfoLabel)
        
        let views = [
            "titleImageView": titleImageView,
            "loadingIndicator": loadingIndicator,
            "progressInfoLabel": progressInfoLabel
        ]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", metrics: nil, views: ["backgroundImageView": backgroundImageView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", metrics: nil, views: ["backgroundImageView": backgroundImageView]))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleImageView]-|", metrics: nil, views: ["titleImageView": titleImageView,]))
        view.addConstraint(NSLayoutConstraint(item: loadingIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: progressInfoLabel, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: loadingIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleImageView]", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[loadingIndicator]-[progressInfoLabel]", metrics: nil, views: views))
        view.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: .width, relatedBy: .equal, toItem: titleImageView, attribute: .height, multiplier: 505.0 / 153.0, constant: 0))
        
        loadingIndicator.startAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let defaults = UserDefaults.standard
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        if let version = defaults.string(forKey: "version"), version == currentVersion { } else {
            defaults.removeObject(forKey: "lastUpdate")
            defaults.removeObject(forKey: "defaultDataLoaded")
            defaults.set(currentVersion, forKey: "version")
        }
        
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
        DownloadService.updateSongs({ progressInfo in
            DispatchQueue.main.async {
                self.progressInfoLabel.text = progressInfo
            }
        }) {
            DispatchQueue.main.async {
                self.navigationController?.present(TabBarController(), animated: false)
                self.loadingIndicator.stopAnimating()
            }
        }
    }
}
