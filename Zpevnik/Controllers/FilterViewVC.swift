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

    private let tags: [Tag] = {
        return CoreDataService.fetchData(predicate: NSPredicate(format: "isValid = true"), context: PersistenceService.backgroundContext) ?? []
    }()
    
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
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(FilterTagCell.self, forCellWithReuseIdentifier: "filterTagCell")
        collectionView.register(FilterTagHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "filterTagHeader")
        
        if #available(iOS 13, *) {
            collectionView.backgroundColor = .systemBackground
        }
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
    }

    private func setViews() {
        view.addSubview(filterTagsView)
        
        filterTagsView.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2).isActive = true
        filterTagsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        filterTagsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        filterTagsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func color(for section: Int) -> UIColor {
        return section == 0 ? .blue : (section == (dataSource?.headers.count ?? 0) - 1 ? .red : .green)
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension FilterViewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource?.headers.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.tags[section].count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterTagCell", for: indexPath) as? FilterTagCell else { return UICollectionViewCell() }
        
        cell.setBackgroundColor(color(for: indexPath.section))
        cell.title = dataSource?.tags[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return FilterTagCell.sizeFor(dataSource?.tags[indexPath.section][indexPath.row])
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "filterTagHeader", for: indexPath) as? FilterTagHeader else { return UICollectionReusableView() }
            
            headerView.title = dataSource?.headers[indexPath.section]

            return headerView
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return FilterTagHeader.sizeFor(dataSource?.headers[section])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FilterTagCell else { return }
        
        dataSource?.activateFilter(indexPath.section, indexPath.row)
        
        cell.setBackgroundColor(color(for: indexPath.section))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FilterTagCell else { return }
        
        dataSource?.deactivateFilter(indexPath.section, indexPath.row)
        
        cell.setBackgroundColor(color(for: indexPath.section))
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FilterTagCell else { return }
        
        cell.setBackgroundColor(color(for: indexPath.section))
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FilterTagCell else { return }
        
        cell.setBackgroundColor(color(for: indexPath.section))
    }
}
