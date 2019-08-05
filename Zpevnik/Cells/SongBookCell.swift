//
//  SongBookCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongBookCell: UITableViewCell {
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.baselineAdjustment = .alignCenters
        
        label.numberOfLines = 0
        
        return label
    }()
    
    let shortcutLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        
        label.textColor = .white
        label.backgroundColor = .red
        
        label.layer.cornerRadius = 20
        label.clipsToBounds = true
        
        label.setInsets(right: 5, left: 5)
        
        return label
    }()
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        shortcutLabel.backgroundColor = .red
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        shortcutLabel.backgroundColor = .red
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(shortcutLabel)
        addSubview(nameLabel)
        
        let views = [
            "shortcutLabel": shortcutLabel,
            "nameLabel": nameLabel
        ]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[shortcutLabel(40)]-[nameLabel]-|", metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=8)-[shortcutLabel]", metrics: nil, views: views))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLabel]-|", metrics: nil, views: views))
        addConstraint(NSLayoutConstraint(item: shortcutLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: shortcutLabel, attribute: .width, relatedBy: .equal, toItem: shortcutLabel, attribute: .height, multiplier: 1, constant: 0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }    
}
