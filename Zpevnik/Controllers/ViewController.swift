//
//  ViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 03/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if #available(iOS 13, *) {
            return .default
        } else {
            return UserSettings.darkMode ? .lightContent : .default
        }
    }
    
    internal func setTitle(_ title: String?, iconImage: UIImage? = nil) {
        let view = UIView()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.textAlignment = .center
        
        view.addSubview(label)
        if iconImage != nil {
            let icon = UIImageView(image: iconImage)
            icon.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(icon)
            
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[icon(==40)]-[label]-|", metrics: nil, views: ["icon": icon, "label": label]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[icon(==40)]|", options: [.alignAllCenterY], metrics: nil, views: ["icon": icon, "label": label]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [.alignAllCenterY], metrics: nil, views: ["icon": icon, "label": label]))
        } else {
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", metrics: nil, views: ["label": label]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [.alignAllCenterY], metrics: nil, views: ["label": label]))
        }
        
        navigationItem.titleView = view
        navigationItem.title = ""
    }
}

class VC: ViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
        }
    }
}
