//
//  ButtonView.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 04/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class ButtonView: GradientView {

    let iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.tintColor = .white
        
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont(name: "Cocogoose Pro", size: 30)
        label.textColor = .white
        
        return label
    }()
    
    let summaryLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.font = UIFont.getFont(ofSize: 12)
        label.textColor = .white
        
        label.numberOfLines = 0
        
        return label
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, summaryLabel])
        
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 0
        
        return stackView
    }()
    
    var icon: UIImage? {
        didSet {
            iconView.image = icon
        }
    }
    
    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }
    
    var summary: String? {
        didSet {
            summaryLabel.text = summary
        }
    }
    
    var stackViewWidthConstraint: NSLayoutConstraint?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        stackViewWidthConstraint?.constant = titleLabel.intrinsicContentSize.width
        
        titleLabel.textColor = .white
        titleLabel.font = UIFont(name: "Cocogoose Pro", size: 30)
        summaryLabel.textColor = .white
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layer.cornerRadius = 15
        clipsToBounds = true
        
        addSubview(iconView)
        addSubview(stackView)
        
        let views = [
            "iconView": iconView,
            "stackView": stackView
        ]
        
        let metrics = [
            "iconSize": 48,
            "padding": 20
        ]
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(padding)-[iconView(==iconSize)]-(padding)-[stackView]-(>=padding)-|", metrics: metrics, views: views))
        
        addConstraint(NSLayoutConstraint(item: iconView, attribute: .width, relatedBy: .equal, toItem: iconView, attribute: .height, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: iconView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        stackViewWidthConstraint = NSLayoutConstraint(item: stackView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 0)
        addConstraint(stackViewWidthConstraint!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
