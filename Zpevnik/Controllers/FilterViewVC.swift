//
//  FilterVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 05/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class FilterViewVC: HalfViewController {
    
    private let spacing: CGFloat = 8
    
    var dataSource: FilterTagDataSource? {
        didSet {
            guard let dataSource = dataSource else { return }
            for (i, arr) in dataSource.active.enumerated() {
                for (j, active) in arr.enumerated() {
                    if active {
                        filterTagsView.selectItem(at: IndexPath(row: j, section: i), animated: false, scrollPosition: .top)
                    }
                }
            }
        }
    }
    
    private lazy var filterTagsView: UICollectionView = {
        let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left)
        
        layout.minimumLineSpacing = 3 * spacing / 4
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: 0, bottom: spacing, right: 0)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 2 * spacing, bottom: 0, right: 2 * spacing)
        
        collectionView.dataSource = dataSource
        collectionView.delegate = dataSource
        
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(FilterTagCell.self, forCellWithReuseIdentifier: "filterTagCell")
        collectionView.register(FilterTagHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "filterTagHeader")
        
        if #available(iOS 13, *) {
            collectionView.backgroundColor = .systemBackground
        } else {
            collectionView.backgroundColor = .white
        }
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let transitioningDelegate = transitioningDelegate as? HalfViewPresentationManager {
            filterTagsView.scrollIndicatorInsets.bottom = filterTagsView.frame.height * (1 - transitioningDelegate.heightMultiplier)
            filterTagsView.contentInset.bottom = filterTagsView.frame.height * (1 - transitioningDelegate.heightMultiplier)
        }
    }

    private func setViews() {
        containerView.addSubview(filterTagsView)
        
        filterTagsView.topAnchor.constraint(equalToSystemSpacingBelow: containerView.topAnchor, multiplier: 2).isActive = true
        filterTagsView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        filterTagsView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        filterTagsView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
    }
}
