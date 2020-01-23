//
//  MoreOptionsTableViewCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 21/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class MoreOptionsCell: UITableViewCell {
    
    var icon: UIImage? {
        didSet {
            iconView.image = icon?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var title: String? {
        didSet {
            titleView.text = title
        }
    }
    
    private lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = .icon
        
        return imageView
    }()
    
    private lazy var titleView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .icon
        
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if #available(iOS 13, *) {
            backgroundColor = .systemBackground
        }
        
        setViews()
    }
    
    private func setViews() {
        addSubview(iconView)
        addSubview(titleView)
        
        iconView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1).isActive = true
        titleView.leadingAnchor.constraint(equalToSystemSpacingAfter: iconView.trailingAnchor, multiplier: 1).isActive = true
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[titleView]-|", metrics: nil, views: ["titleView": titleView]))
        
        iconView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        titleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
