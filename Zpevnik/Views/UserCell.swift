//
//  UserCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class UserCell: UIView {
    
    var userName: String? {
        didSet {
            userNameLabel.text = userName
        }
    }
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let settingsIcon: UIImageView = {
        let imageView = UIImageView(image: )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViews()
    }
    
    private func setViews() {
        addSubview(userNameLabel)
        
        userNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1).isActive = true
        userNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1).isActive = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
