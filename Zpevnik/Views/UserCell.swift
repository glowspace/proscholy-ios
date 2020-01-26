//
//  UserCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class UserCell: UIView {
    
    var delegate: UserCellDelegate?
    
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
    
    private let menuIcon: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage.menu?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .icon
        
        button.addTarget(self, action: #selector(showUserMenu), for: .touchUpInside)
        
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViews()
    }
    
    private func setViews() {
        addSubview(userNameLabel)
        addSubview(menuIcon)
        
        userNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1).isActive = true
        userNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        menuIcon.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8).isActive = true
        menuIcon.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Handlers

extension UserCell {
    
    @objc func showUserMenu() {
        delegate?.showUserMenu()
    }
}
