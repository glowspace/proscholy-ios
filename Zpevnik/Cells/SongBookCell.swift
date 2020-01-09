//
//  SongBookCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongBookCell: UICollectionViewCell {
    
    var songBookName: String? {
        willSet {
            songBookNameLabel.text = newValue
        }
    }
    
    private lazy var songBookImageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        
        imageView.backgroundColor = .red
        
        return imageView
    }()
    
    private lazy var songBookNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViews()
    }
    
    private func setViews() {
        addSubview(songBookImageView)
        addSubview(songBookNameLabel)
        
        songBookImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        songBookImageView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        songBookImageView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        songBookImageView.widthAnchor.constraint(equalTo: songBookImageView.heightAnchor, multiplier: 4 / 3, constant: 0).isActive = true
        
        songBookNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: songBookImageView.bottomAnchor, multiplier: 1).isActive = true
        songBookNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        songBookNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        songBookNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//class SongBookCell: TableViewCell {
//
//    let nameLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        label.baselineAdjustment = .alignCenters
//
//        label.numberOfLines = 0
//
//        return label
//    }()
//
//    let shortcutLabel: PaddingLabel = {
//        let label = PaddingLabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        label.textAlignment = .center
//        label.baselineAdjustment = .alignCenters
//
//        label.adjustsFontSizeToFitWidth = true
//        label.minimumScaleFactor = 0.2
//
//        label.textColor = .white
//        label.backgroundColor = .red
//
//        label.layer.cornerRadius = 20
//        label.clipsToBounds = true
//
//        label.setInsets(right: 5, left: 5)
//
//        return label
//    }()
//
//    var shortcutBackgroundColor: UIColor? {
//        didSet {
//            if let color = shortcutBackgroundColor {
//                shortcutLabel.backgroundColor = color
//            }
//        }
//    }
//
//    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
//        super.setHighlighted(highlighted, animated: animated)
//
//        shortcutLabel.backgroundColor = shortcutBackgroundColor
//        shortcutLabel.textColor = .white
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        shortcutLabel.backgroundColor = shortcutBackgroundColor
//        shortcutLabel.textColor = .white
//    }
//
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//
//        shortcutLabel.textColor = .white
//    }
//
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        addSubview(shortcutLabel)
//        addSubview(nameLabel)
//
//        let views = [
//            "shortcutLabel": shortcutLabel,
//            "nameLabel": nameLabel
//        ]
//
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[shortcutLabel(40)]-[nameLabel]-|", metrics: nil, views: views))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[shortcutLabel]", metrics: nil, views: views))
//        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[nameLabel]-|", metrics: nil, views: views))
//        addConstraint(NSLayoutConstraint(item: shortcutLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
//        addConstraint(NSLayoutConstraint(item: shortcutLabel, attribute: .width, relatedBy: .equal, toItem: shortcutLabel, attribute: .height, multiplier: 1, constant: 0))
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
