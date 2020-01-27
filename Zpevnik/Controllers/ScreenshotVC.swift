//
//  ScreenShotVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 27/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class ScreenshotVC: UIViewController {
    
    var screenshottedVC: UIViewController?
    
    var screenshot: UIImage? {
        didSet {
            screenshotView.image = screenshot
        }
    }
    
    private let screenshotView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.backgroundColor = .clear
        
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    private func setViews() {
        view.addSubview(screenshotView)

        screenshotView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        screenshotView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        screenshotView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        screenshotView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
