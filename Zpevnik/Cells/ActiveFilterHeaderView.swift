//
//  ActiveFilterHeaderView.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 07/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class ActiveFilterHeaderView: UIView {
    
    private lazy var filterImageView: UIImageView = {
        let imageView = UIImageView(image: .filter)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13, *) {
            imageView.tintColor = .systemGray2
        }
        
        return imageView
    }()
    
    private lazy var selectedFiltersView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.register(ClearAbleFilterTagCell.self, forCellWithReuseIdentifier: "clearableFilterTagCell")
        
        return collectionView
    }()
    
    init(dataSource: UICollectionViewDataSource, delegate: UICollectionViewDelegate) {
        super.init(frame: .zero)
        
        selectedFiltersView.dataSource = dataSource
        selectedFiltersView.delegate = delegate
        
        setViews()
    }
    
    private func setViews() {
        addSubview(filterImageView)
        addSubview(selectedFiltersView)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[filterImageView]-|", metrics: nil, views: ["filterImageView": filterImageView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-4-[selectedFiltersView]-4-|", metrics: nil, views: ["selectedFiltersView": selectedFiltersView]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[filterImageView]-[selectedFiltersView]-|", metrics: nil, views: ["filterImageView": filterImageView, "selectedFiltersView": selectedFiltersView]))
        
        filterImageView.heightAnchor.constraint(equalTo: filterImageView.widthAnchor).isActive = true
        filterImageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
