//
//  SearchView.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 29/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SearchView: UIView {
    
    let leadingButton: UIButton?
    let trailingButton: UIButton?
    
    lazy var searchField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.contentVerticalAlignment = .center
        
        textField.font = UIFont.systemFont(ofSize: 20)
        textField.returnKeyType = .search
        
        textField.enablesReturnKeyAutomatically = true
        
        return textField
    }()
    
    init(leadingButton: UIButton? = nil, trailingButton: UIButton? = nil) {
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13, *) {
            backgroundColor = .systemBackground
        }
        
        updateBorder()
        setViews()
    }
    
    func updateBorder() {
        if #available(iOS 13, *) {
            layer.borderColor = UIColor.separator.cgColor
        } else {
            layer.borderColor = UIColor(white: 0.2, alpha: 1).cgColor
        }
        
        layer.borderWidth = 1
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    private func setViews() {
        addSubview(searchField)
        
        leadingButton?.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        trailingButton?.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        leadingButton?.tintColor = .icon
        trailingButton?.tintColor = .icon
        
        if let leadingButton = leadingButton {
            leadingButton.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(leadingButton)
            leadingButton.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            searchField.leadingAnchor.constraint(equalTo: leadingButton.trailingAnchor).isActive = true
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[leadingButton]|", metrics: nil, views: ["leadingButton": leadingButton]))
            
            leadingButton.widthAnchor.constraint(equalTo: leadingButton.heightAnchor).isActive = true
        } else {
            searchField.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1).isActive = true
        }
        
        if let trailingButton = trailingButton {
            trailingButton.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(trailingButton)
            trailingButton.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            trailingButton.leadingAnchor.constraint(equalToSystemSpacingAfter: searchField.trailingAnchor, multiplier: 1).isActive = true
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[trailingButton]|", metrics: nil, views: ["trailingButton": trailingButton]))
            
            trailingButton.widthAnchor.constraint(equalTo: trailingButton.heightAnchor).isActive = true
        } else {
            searchField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1).isActive = true
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[searchField]|", metrics: nil, views: ["searchField": searchField]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

