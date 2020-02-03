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
        
        imageView.backgroundColor = .blue
        
        return imageView
    }()
    
    private lazy var songBookNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .preferredFont(forTextStyle: .body)
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
