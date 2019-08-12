//
//  SongLyriCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongLyricCell: TableViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.baselineAdjustment = .alignCenters
        
        label.numberOfLines = 0
        
        return label
    }()
    
    let numberLabel: UILabel = {
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
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    
    var favorite: Bool!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            if favorite {
                trailingConstraint.constant = -48
            } else {
                leadingConstraint.constant = 48
            }
        } else {
            if favorite {
                trailingConstraint.constant = -8
            } else {
                leadingConstraint.constant = 8
            }
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            self.layoutIfNeeded()
        })
    }
    
    private func setViews() {
        addSubview(containerView)
        
        containerView.addSubview(nameLabel)
        containerView.addSubview(numberLabel)
        
        let views = [
            "nameLabel": nameLabel,
            "numberLabel": numberLabel
        ]
        
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[nameLabel]-[numberLabel(==60)]-|", metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[nameLabel]|", metrics: nil, views: views))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[numberLabel]|", metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[containerView]-|", metrics: nil, views: ["containerView": containerView]))
        
        leadingConstraint = containerView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1)
        leadingConstraint.isActive = true
        trailingConstraint = containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        trailingConstraint.isActive = true
    }
}
