//
//  FilterTagsDataSource.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 08/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

class FilterTagDataSource: NSObject {
    
    private var headers: [String]
    var tags: [[String]]
    var active: [[Bool]]
    
    var activeFilters: [String] {
        var tmp = [String]()
        
        for (i, t) in tags.enumerated() {
            for (j, tag) in t.enumerated() {
                if active[i][j] {
                    tmp.append(tag)
                }
            }
        }
        
        return tmp
    }
    
    var delegate: FilterDelegate?
    
    override init() {
        headers = []
        tags = []
        active = []
        
        super.init()
        
        setTags()
    }
    
    func activateFilter(_ section: Int, _ row: Int) {
        if !active[section][row] {
            active[section][row] = true
            delegate?.activeFiltersChanged()
        }
    }
    
    func deactivateFilter(_ section: Int, _ row: Int) {
        if active[section][row] {
            active[section][row] = false
            delegate?.activeFiltersChanged()
        }
    }
    
    func deactivateFilter(named filterName: String) {
        for (i, t) in tags.enumerated() {
            for (j, tag) in t.enumerated() {
                if tag == filterName && active[i][j] {
                    deactivateFilter(i, j)
                    return
                }
            }
        }
    }
    
    func predicateForSection(_ section: Int, _ filteredTags: [String]) -> NSPredicate {
        return section == headers.count - 1 ? NSPredicate(format: "language in %@", filteredTags) : NSPredicate(format: "ANY tags.name in %@", filteredTags)
    }
    
    private func setTags() {
        guard let allTags: [Tag] = CoreDataService.fetchData(predicate: NSPredicate(format: "isValid = true"), context: PersistenceService.backgroundContext) else { return }
        guard let languages: [Language] = CoreDataService.fetchData(predicate: NSPredicate(format: "count > 0"), sortDescriptors: [NSSortDescriptor(key: "count", ascending: false)], context: PersistenceService.backgroundContext) else { return }
        
        let parentTags = allTags.filter { $0.children?.anyObject() != nil }.sorted { $0.id!.localizedStandardCompare($1.id!) == .orderedAscending }
        let tagsWithoutParent = allTags.filter { $0.children?.anyObject() == nil && $0.parent == nil }.sorted { $0.id!.localizedStandardCompare($1.id!) == .orderedAscending }
        
        headers.append("Liturgie - mše svatá")
        tags.append([])
        active.append([])
        for tag in tagsWithoutParent {
            if let name = tag.name {
                tags[tags.count - 1].append(name)
                active[active.count - 1].append(false)
            }
        }
        
        for tag in parentTags {
            if let name = tag.name {
                headers.append(name.capitalizingFirstLetter())
                
                tags.append([])
                active.append([])
                if let children = tag.children?.allObjects as? [Tag] {
                    let sortedChildren = children.sorted { $0.id!.localizedStandardCompare($1.id!) == .orderedAscending }
                    for childTag in sortedChildren {
                        if let childName = childTag.name {
                            tags[tags.count - 1].append(childName)
                            active[active.count - 1].append(false)
                        }
                    }
                }
            }
        }
        
        headers.append("Jazyky")
        tags.append([])
        active.append([])
        for language in languages {
            if let name = language.name {
                tags[tags.count - 1].append(name)
                active[active.count - 1].append(false)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout

extension FilterTagDataSource: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return headers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterTagCell", for: indexPath) as? FilterTagCell else { return UICollectionViewCell() }
        
        cell.setBackgroundColor(color(for: indexPath.section))
        cell.title = tags[indexPath.section][indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "filterTagHeader", for: indexPath) as? FilterTagHeader else { return UICollectionReusableView() }
            
            headerView.title = headers[indexPath.section]

            return headerView
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return FilterTagCell.sizeFor(tags[indexPath.section][indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return FilterTagHeader.sizeFor(headers[section])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FilterTagCell else { return }
        
        activateFilter(indexPath.section, indexPath.row)
        
        cell.setBackgroundColor(color(for: indexPath.section))
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? FilterTagCell else { return }
        
        deactivateFilter(indexPath.section, indexPath.row)
        
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
    
    private func color(for section: Int) -> UIColor {
        return section == 0 ? .blue : (section == (headers.count - 1) ? .red : .green)
    }
}
