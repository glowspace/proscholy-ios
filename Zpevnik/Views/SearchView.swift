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
    
    lazy var searchField: TextField = {
        let textField = TextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.contentVerticalAlignment = .center
        
        textField.font = UIFont.getFont(ofSize: 20)
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
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[leadingButton][searchField]", metrics: nil, views: ["searchField": searchField, "leadingButton": leadingButton]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[leadingButton]|", metrics: nil, views: ["leadingButton": leadingButton]))
            
            leadingButton.widthAnchor.constraint(equalTo: leadingButton.heightAnchor).isActive = true
        } else {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchField]", metrics: nil, views: ["searchField": searchField]))
        }
        
        if let trailingButton = trailingButton {
            trailingButton.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(trailingButton)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[searchField][trailingButton]|", metrics: nil, views: ["searchField": searchField, "trailingButton": trailingButton]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[trailingButton]|", metrics: nil, views: ["trailingButton": trailingButton]))
            
            trailingButton.widthAnchor.constraint(equalTo: trailingButton.heightAnchor).isActive = true
        } else {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[searchField]-|", metrics: nil, views: ["searchField": searchField]))
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[searchField]|", metrics: nil, views: ["searchField": searchField]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

