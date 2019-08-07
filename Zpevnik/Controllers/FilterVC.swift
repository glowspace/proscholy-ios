//
//  FilterVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 05/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class FilterVC: UIViewController {
    
    let tags = [
        ["vstup", "úkon kajícnosti", "před evangeliem", "přinášení darů", "k přijímání", "po přijímání", "závěr", "ordinarium"],
        ["dětské", "hymny setkání mládeže", "žalm", "život s Ježíšem"],
        ["křest", "svatební", "za zemřelé"],
        ["k Duchu Svatému", "ke svatým", "Panna Maria", "sv. Josef", "sv. Jan Bosco"],
        ["adorace", "chvály", "díky", "prosby"],
        ["koleda", "Vánoce", "Velikonoce", "advent", "postní doba", "ke křížové cestě"]
    ]
    
    let colors: [UIColor] = [.blue, .red, .green, .magenta, .purple, .cyan]
    
    lazy var labels: [[UILabel]] = {
        return tags.enumerated().map { (arg) -> [UILabel] in
            let (index, tags) = arg
            return tags.map {
                createLabel($0, color: colors[index])
            }
        }
    }()
    
    lazy var tagsView: UICollectionView = {
        let layout = AlignedCollectionViewFlowLayout(horizontalAlignment: .left)
        
        layout.minimumLineSpacing = 3
        layout.sectionInset = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.backgroundColor = .white
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsMultipleSelection = true
        
        collectionView.register(FilterTagCell.self, forCellWithReuseIdentifier: "cellId")
        
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
        
        view.backgroundColor = .white
        
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
        
        for (section, _) in tags.enumerated() {
            for (row, _) in tags[section].enumerated() {
                tagsView.selectItem(at: IndexPath(row: row, section: section), animated: true, scrollPosition: [])
            }
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
    
    private func createLabel(_ title: String, color: UIColor) -> UILabel {
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

extension FilterVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        
        cell.addSubview(labels[indexPath.section][indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return labels[indexPath.section][indexPath.row].frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.alpha = 1
        
        if let selected = collectionView.indexPathsForSelectedItems, selected.count == tags.reduce(0) { $0 + $1.count } {
            for (section, _) in tags.enumerated() {
                for (row, _) in tags[section].enumerated() {
                    collectionView.deselectItem(at: IndexPath(row: row, section: section), animated: true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        collectionView.cellForItem(at: indexPath)?.alpha = 0.25
        
        if collectionView.indexPathsForSelectedItems == nil {
            for (section, _) in tags.enumerated() {
                for (row, _) in tags[section].enumerated() {
                    collectionView.selectItem(at: IndexPath(row: row, section: section), animated: true, scrollPosition: [])
                }
            }
        }
    }
}
