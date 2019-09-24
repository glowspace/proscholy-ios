//
//  FilterVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 05/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class FilterVC: ViewController {
    
    var delegate: FilterDelegate?
    
    let colors: [UIColor] = [.blue, .red, .green, .magenta, .purple, .cyan]
    
    let tags: [Tag] = {
        return CoreDataService.fetchData(context: PersistenceService.context) ?? []
    }()
    
    lazy var mainSections: [FilterTag] = {
        let defaultTag = Tag(entity: Tag.entity(), insertInto: nil)
        defaultTag.name = "Filtry"
        
        var sections: [FilterTag] = [defaultTag]
        sections.append(contentsOf: tags.filter {
            if $0.elements.count > 0 {
                return true
            }
            
            if $0.parent == nil {
                defaultTag.addToChildren($0)
            }
            
            return false
        })
        
        let languageTag = LanguageTag()
        sections.append(languageTag)
        
        return sections
    }()

    lazy var usingFilter: [Bool] = {
        return mainSections.map { _ in return false }
    }()
    
    lazy var selected: [[Bool]] = {
        return mainSections.map { $0.elements.map { _ in return true } }
    }()
    
    lazy var labels: [[UILabel]] = mainSections.enumerated().map {
        let (i, section) = $0

        return section.elements.map { createLabel($0.name, color: colors[i]) }
    }
    
    lazy var tagsView: UICollectionView = {
        let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left)
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: ("A" as NSString).boundingRect(with: CGSize(width: 0, height: 0), options: .usesLineFragmentOrigin, attributes: [.font: UIFont.getFont(ofSize: 17)], context: nil).height + 16)
        
        layout.minimumLineSpacing = 5
        layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(FilterTagCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "headerId")
        
        for row in 0..<tags.count {
            collectionView.selectItem(at: IndexPath(row: row, section: 0), animated: true, scrollPosition: [])
        }
        
        return collectionView
    }()
    
    let indicator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 2.5
        view.clipsToBounds = true
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        return view
    }()
    
    var tagsViewTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = view.bounds
        rectShape.position = view.center
        rectShape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        
        view.layer.backgroundColor = UIColor.green.cgColor
        view.layer.mask = rectShape
        
        view.addSubview(tagsView)
        view.addSubview(indicator)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tagsView]|", metrics: nil, views: ["tagsView": tagsView]))
        indicator.heightAnchor.constraint(equalToConstant: 5).isActive = true
        indicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        indicator.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5).isActive = true
        tagsViewTopConstraint = tagsView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0)
        tagsViewTopConstraint.isActive = true
        tagsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13, *) {
            view.backgroundColor = Constants.getMiddleColor(traitCollection.userInterfaceStyle) ?? .white
            tagsView.backgroundColor = Constants.getMiddleColor(traitCollection.userInterfaceStyle) ?? .white
        } else {
            view.backgroundColor = Constants.getMiddleColor() ?? .white
            tagsView.backgroundColor = Constants.getMiddleColor() ?? .white
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        tagsView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = view.frame
        rectShape.position = view.center
        rectShape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 15, height: 15)).cgPath
        
        tagsViewTopConstraint.constant = view.frame.height * 0.25
        view.layer.mask = rectShape
    }
    
    private func createLabel(_ title: String?, color: UIColor) -> UILabel {
        let label = PaddingLabel()
        
        label.setInsets(top: 5, right: 5, bottom: 5, left: 5)
        
        label.text = title
        label.sizeToFit()
        
        label.layer.cornerRadius = label.frame.height / 2.0
        label.clipsToBounds = true
        
        label.backgroundColor = color.withAlphaComponent(0.3)
        
        label.layer.borderColor = color.cgColor
        label.layer.borderWidth = 1
        
        return label
    }
}

extension FilterVC {
    
    var selectedTags: [[FilterAble]] {
        get {
            var selectedTags = [[FilterAble]]()
            
            mainSections.enumerated().forEach {
                let (i, section) = $0
                selectedTags.append([])
                section.elements.enumerated().forEach {
                    let (j, tag) = $0
                    if selected[i][j] {
                        selectedTags[i].append(tag)
                    }
                }
            }
            
            return selectedTags
        }
    }
    
    func clearFilters() {
        for section in 0..<selected.count {
            for row in 0..<selected[section].count {
                selected[section][row] = true
                tagsView.cellForItem(at: IndexPath(row: row, section: section))?.alpha = 1
            }
        }
        
        for i in 0..<usingFilter.count {
            usingFilter[i] = false
        }
        
        delegate?.updateSelected()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 13, *) {
            view.backgroundColor = Constants.getMiddleColor(traitCollection.userInterfaceStyle) ?? .white
            tagsView.backgroundColor = Constants.getMiddleColor(traitCollection.userInterfaceStyle) ?? .white
        } 
    }
}

extension FilterVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return mainSections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainSections[section].elements.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath)
            
            for subview in headerView.subviews {
                if subview is UILabel {
                    subview.removeFromSuperview()
                }
            }
            
            let label = UILabel()
            
            label.text = mainSections[indexPath.section].title
            label.sizeToFit()
            
            label.translatesAutoresizingMaskIntoConstraints = false
            
            headerView.addSubview(label)
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]", metrics: nil, views: ["label": label]))
            headerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-|", metrics: nil, views: ["label": label]))
            
            return headerView
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! FilterTagCell
        
        cell.addSubview(labels[indexPath.section][indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return labels[indexPath.section][indexPath.row].frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = selected[indexPath.section][indexPath.row] ? 1 : 0.25
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCell(collectionView, didDeselectItemAt: indexPath)
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selectedCell(collectionView, didDeselectItemAt: indexPath)
    }
    
    private func selectedCell(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        selected[indexPath.section][indexPath.row] = !selected[indexPath.section][indexPath.row]
        
        if !usingFilter[indexPath.section] {
            usingFilter[indexPath.section] = true
            
            mainSections[indexPath.section].elements.enumerated().forEach {
                let (i, _) = $0
                let indexPath = IndexPath(row: i, section: indexPath.section)
                
                selected[indexPath.section][indexPath.row] = !selected[indexPath.section][indexPath.row]
                collectionView.cellForItem(at: indexPath)?.alpha = selected[indexPath.section][indexPath.row] ? 1 : 0.25
            }
        } else {
            collectionView.cellForItem(at: indexPath)?.alpha = selected[indexPath.section][indexPath.row] ? 1 : 0.25
            
            if selectedTags[indexPath.section].count == 0 {
                usingFilter[indexPath.section] = false
                
                mainSections[indexPath.section].elements.enumerated().forEach {
                    let (i, _) = $0
                    
                    let indexPath = IndexPath(row: i, section: indexPath.section)
                    
                    selected[indexPath.section][indexPath.row] = true
                    collectionView.cellForItem(at: indexPath)?.alpha = selected[indexPath.section][indexPath.row] ? 1 : 0.25
                }
            }
        }
        
        delegate?.updateSelected()
    }
}
