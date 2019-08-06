//
//  SettingCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 04/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        
        return switchButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(titleLabel)
        addSubview(switchButton)
        
        let views = [
            "titleLabel": titleLabel,
            "switchButton": switchButton
        ]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-[switchButton]-|", metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|", metrics: nil, views: views))
        addConstraint(NSLayoutConstraint(item: switchButton, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
