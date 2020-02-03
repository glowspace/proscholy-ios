//
//  UITableViewHeader.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 01/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class TableViewHeader: UIView {
    
    private let spacing: CGFloat = 16
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    init(_ title: String, _ titleColor: UIColor) {
        super.init(frame: .zero)
        
        label.text = title
        label.textColor = titleColor
        
        setViews()
    }
    
    private func setViews() {
        addSubview(label)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(spacing)-[label]-(spacing)-|", metrics: ["spacing": spacing], views: ["label": label]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-|", metrics: nil, views: ["label": label]))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
