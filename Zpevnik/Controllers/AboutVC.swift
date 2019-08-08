//
//  AboutVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 08/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class AboutVC: UIViewController {
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.numberOfLines = 0
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(descriptionLabel)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[descriptionLabel]-|", metrics: nil, views: ["descriptionLabel": descriptionLabel]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[descriptionLabel]", metrics: nil, views: ["descriptionLabel": descriptionLabel]))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = Constants.getDarkColor() ?? .groupTableViewBackground
    }
}
