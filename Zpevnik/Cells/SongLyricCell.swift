//
//  SongLyriCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongLyricCell: UITableViewCell {
    
    private let horizontalSpacing: CGFloat = 16
    private let verticalSpacing: CGFloat = 12
    
    var name: String? {
        didSet {
            nameLabel.text = name
        }
    }
    
    var number: String? {
        didSet {
            numberLabel.text = number
        }
    }
    
    var favorite = false {
        didSet {
            starIconWidthConstraint?.constant = favorite ? 16 : 0
        }
    }
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.baselineAdjustment = .alignCenters
        
        label.numberOfLines = 0
        
        return label
    }()
    
    private let starIcon: UIImageView = {
        let imageView = UIImageView(image: .starFilled)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = UIColor.inverted.withAlphaComponent(0.5)
        
        return imageView
    }()
    
    private let numberLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        
        label.font = UIFont.getFont(ofSize: 13)
        label.textColor = .gray
        
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .right
        
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var leadingConstraint: NSLayoutConstraint?
    private var starIconWidthConstraint: NSLayoutConstraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if #available(iOS 13, *) {
            backgroundColor = .systemBackground
        }
        
        tintColor = .blue
        
        setViews()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        leadingConstraint?.constant = editing ? 48 : horizontalSpacing
        
        UIView.animate(withDuration: animated ? 0.3 : 0) {
            self.layoutIfNeeded()
        }
    }
    
    private func setViews() {
        addSubview(containerView)

        containerView.addSubview(nameLabel)
        containerView.addSubview(starIcon)
        containerView.addSubview(numberLabel)

        let views = [
            "nameLabel": nameLabel,
            "starIcon": starIcon,
            "numberLabel": numberLabel
        ]

        nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        starIcon.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: nameLabel.trailingAnchor, multiplier: 1).isActive = true
        numberLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: starIcon.trailingAnchor, multiplier: 1).isActive = true
        numberLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        numberLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        starIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        numberLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[nameLabel]|", metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[containerView]-(spacing)-|", metrics: ["spacing": verticalSpacing], views: ["containerView": containerView]))
        
        starIcon.heightAnchor.constraint(equalTo: starIcon.widthAnchor).isActive = true
        starIconWidthConstraint = starIcon.widthAnchor.constraint(equalToConstant: 0)
        starIconWidthConstraint?.isActive = true
        
        leadingConstraint = containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalSpacing)
        leadingConstraint?.isActive = true
        
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalSpacing).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
