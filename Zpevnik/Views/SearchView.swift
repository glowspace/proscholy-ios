//
//  SearchView.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 29/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SearchView: UIView {
    
    private let leadingView: UIView?
    private let trailingView: UIView?
    
    lazy var searchField: TextField = {
        let textField = TextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.contentVerticalAlignment = .center
        
        textField.delegate = self
        
        textField.font = UIFont.getFont(ofSize: 20)
        textField.clearButtonMode = .always
        textField.returnKeyType = .search
        
        return textField
    }()
    
    init(leadingView: UIView? = nil, trailingView: UIView? = nil) {
        self.leadingView = leadingView
        self.trailingView = trailingView
        
        super.init(frame: .zero)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        updateBorder()
        setViews()
    }
    
    func updateBorder() {
        layer.borderWidth = 1
        if #available(iOS 13, *) {
            layer.borderColor = UIColor.systemGray5.cgColor
        } else {
            layer.borderColor = UIColor.lightGray.cgColor
        }
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    private func setViews() {
        addSubview(searchField)
        
        if let leadingView = leadingView {
            leadingView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(leadingView)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[leadingView]-[searchField]", metrics: nil, views: ["searchField": searchField, "leadingView": leadingView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[leadingView]-4-|", metrics: nil, views: ["leadingView": leadingView]))
            
            leadingView.widthAnchor.constraint(equalTo: leadingView.heightAnchor).isActive = true
        } else {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchField]", metrics: nil, views: ["searchField": searchField]))
        }
        
        if let trailingView = trailingView {
            trailingView.translatesAutoresizingMaskIntoConstraints = false
            
            addSubview(trailingView)
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[searchField]-[trailingView]-|", metrics: nil, views: ["searchField": searchField, "trailingView": trailingView]))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[trailingView]-4-|", metrics: nil, views: ["trailingView": trailingView]))
            
            trailingView.widthAnchor.constraint(equalTo: trailingView.heightAnchor).isActive = true
        } else {
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[searchField]-|", metrics: nil, views: ["searchField": searchField]))
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[searchField]|", metrics: nil, views: ["searchField": searchField]))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SearchView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

