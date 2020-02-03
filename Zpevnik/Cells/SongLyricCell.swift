//
//  SongLyriCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongLyricCell: UITableViewCell {
    
    var horizontalSpacing: CGFloat = 16 {
        willSet {
            leadingConstraint?.constant = newValue
            trailingConstraint?.constant = -newValue
        }
    }
    var verticalSpacing: CGFloat = 12 {
        willSet {
            topConstraint?.constant = newValue
            bottomConstraint?.constant = -newValue
        }
    }
    
    private var topConstraint, bottomConstraint, leadingConstraint, trailingConstraint, starIconWidthConstraint: NSLayoutConstraint?
    
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
        
        label.font = .preferredFont(forTextStyle: .footnote)
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if #available(iOS 13, *) {
            backgroundColor = .systemBackground
        }
        
        tintColor = .blue
        
        setViews()
    }
    
    private func setViews() {
        contentView.addSubview(containerView)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(starIcon)
        containerView.addSubview(numberLabel)

        nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        starIcon.leadingAnchor.constraint(equalToSystemSpacingAfter: nameLabel.trailingAnchor, multiplier: 1).isActive = true
        numberLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: starIcon.trailingAnchor, multiplier: 1).isActive = true
        numberLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        numberLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        starIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        numberLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        starIcon.heightAnchor.constraint(equalTo: starIcon.widthAnchor).isActive = true
        starIconWidthConstraint = starIcon.widthAnchor.constraint(equalToConstant: 0)
        starIconWidthConstraint?.isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        topConstraint = containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalSpacing)
        bottomConstraint = containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalSpacing)
        leadingConstraint = containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalSpacing)
        trailingConstraint = containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalSpacing)
        
        topConstraint?.isActive = true
        bottomConstraint?.isActive = true
        leadingConstraint?.isActive = true
        trailingConstraint?.isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
