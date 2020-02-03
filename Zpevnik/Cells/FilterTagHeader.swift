//
//  FilterTagHeader.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 04/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class FilterTagHeader: UICollectionReusableView {
    
    var title: String? {
        willSet {
            titleLabel.text = newValue
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = .systemFont(ofSize: 20)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setViews()
    }
    
    private func setViews() {
        
        addSubview(titleLabel)
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[titleLabel]|", metrics: nil, views: ["titleLabel": titleLabel]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleLabel]|", metrics: nil, views: ["titleLabel": titleLabel]))
    }
    
    static func sizeFor(_ text: String?) -> CGSize {
        guard let text = text else { return .zero }
        
        let size = (text as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: 21)])
        return CGSize(width: size.width, height: size.height)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
