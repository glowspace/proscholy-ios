//
//  SongLyriCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongLyricCell: UITableViewCell {

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
        
        label.font = UIFont.systemFont(ofSize: 13)
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
    
    var nameLabelLeadingConstraint: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
        nameLabelLeadingConstraint = NSLayoutConstraint(item: containerView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 8)
        addConstraint(nameLabelLeadingConstraint)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[containerView]|", metrics: nil, views: ["containerView": containerView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[containerView]-|", metrics: nil, views: ["containerView": containerView]))
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing {
            nameLabelLeadingConstraint.constant = 48
        } else {
            nameLabelLeadingConstraint.constant = 8
        }
        
        if editing {
            let checkMarkView = subviews[subviews.count - 1]
            checkMarkView.translatesAutoresizingMaskIntoConstraints = false
            let views = [
                "checkMarkView": checkMarkView,
                "containerView" : containerView
            ]
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[checkMarkView]-[containerView]", metrics: nil, views: views))
            addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[checkMarkView]-|", metrics: nil, views: views))
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.layoutIfNeeded()
            })
        } else {
            self.layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
