//
//  FilterTagCell.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 06/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class ClearAbleFilterTagCell: UICollectionViewCell {
    
    private static let spacing: CGFloat = 8
    private static let clearButtonSize: CGFloat = 16
    
    // TODO: replace with protocol
    var delegate: SongListViewVC?
    
    var color: UIColor?
    
    var title: String? {
        willSet {
            filterLabel.text = newValue
            
            setViews()
        }
    }
    
    private lazy var clearButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(UIImage.clear?.withRenderingMode(.alwaysTemplate), for: .normal)
        if #available(iOS 13, *) {
            button.tintColor = .systemGray2
        }
        
        button.addTarget(self, action: #selector(clearFilter), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var filterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        layer.borderWidth = 1
        
        if #available(iOS 13, *) {
            layer.borderColor = UIColor.systemGray5.cgColor
        }
    }
    
    private func setViews() {
        layer.cornerRadius = frame.height / 2.0
        
        addSubview(filterLabel)
        addSubview(clearButton)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(spacing)-[filterLabel][clearButton]-(spacing)-|", options: [.alignAllCenterY], metrics: ["spacing": ClearAbleFilterTagCell.spacing], views: ["filterLabel": filterLabel, "clearButton": clearButton]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[filterLabel]-(spacing)-|", metrics: ["spacing": ClearAbleFilterTagCell.spacing / 2], views: ["filterLabel": filterLabel]))
        
        clearButton.heightAnchor.constraint(equalToConstant: ClearAbleFilterTagCell.clearButtonSize).isActive = true
        clearButton.heightAnchor.constraint(equalTo: clearButton.widthAnchor).isActive = true
    }
    
    @objc func clearFilter() {
        delegate?.removeFilter(title)
    }
    
    static func sizeFor(_ text: String?) -> CGSize {
        guard let text = text else { return .zero }
        
        let size = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 17)])
        return CGSize(width: size.width + 2 * spacing + clearButtonSize, height: size.height + spacing)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FilterTagCell: UICollectionViewCell {
    
    private static let spacing: CGFloat = 6
    
    var color: UIColor?
    
    var title: String? {
        willSet {
            filterLabel.text = newValue
            
            setViews()
        }
    }
    
    private lazy var filterLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 16)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        clipsToBounds = true
        layer.borderWidth = 1
        
        if #available(iOS 13, *) {
            layer.borderColor = UIColor.systemGray2.cgColor
        }
    }
    
    func setBackgroundColor(_ color: UIColor) {
        if isSelected {
            backgroundColor = color.withAlphaComponent(0.75)
        } else if isHighlighted {
            backgroundColor = color.withAlphaComponent(0.5)
        } else {
            if #available(iOS 13, *) {
                backgroundColor = .systemBackground
            }
        }
    }
    
    private func setViews() {
        layer.cornerRadius = frame.height / 2.0
        
        addSubview(filterLabel)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(spacing)-[filterLabel]-(spacing)-|", metrics: ["spacing": FilterTagCell.spacing], views: ["filterLabel": filterLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(spacing)-[filterLabel]-(spacing)-|", metrics: ["spacing": FilterTagCell.spacing], views: ["filterLabel": filterLabel]))
    }
    
    static func sizeFor(_ text: String?) -> CGSize {
        guard let text = text else { return .zero }
        
        let size = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 17)])
        return CGSize(width: size.width + 2 * spacing, height: size.height + 2 * spacing)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
