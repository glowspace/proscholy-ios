//
//  SearchView.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 29/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SearchView: UIView {
    
    lazy var searchField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        textField.contentVerticalAlignment = .center
        
        textField.delegate = self
        
        textField.font = UIFont.getFont(ofSize: 17)
        textField.clearButtonMode = .always
        textField.returnKeyType = .search
        
        return textField
    }()
    
    override var intrinsicContentSize: CGSize {
        var size = UIView.layoutFittingExpandedSize
        size.height = 10
        return size
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.lightGray.cgColor
        layer.cornerRadius = 8
        clipsToBounds = true
        
        backgroundColor = .white
        
        let views = [
            "searchField": searchField
        ]
        
        addSubview(searchField)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[searchField]", metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchField]-|", metrics: nil, views: views))
//        addConstraint(NSLayoutConstraint(item: searchField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
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

