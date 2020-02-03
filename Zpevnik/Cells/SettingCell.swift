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
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        
        return label
    }()
    
    let switchButton: UISwitch = {
        let switchButton = UISwitch()
        switchButton.translatesAutoresizingMaskIntoConstraints = false
        
        switchButton.layer.cornerRadius = 16
        
        return switchButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setViews()
    }
    
    private func setViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(switchButton)
        
        let views = [
            "titleLabel": titleLabel,
            "switchButton": switchButton
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleLabel]-[switchButton]-|", options: [.alignAllCenterY], metrics: nil, views: views))
        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleLabel]-|", metrics: nil, views: views))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
