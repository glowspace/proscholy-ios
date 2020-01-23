//
//  SlidingView.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 22/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SlidingView: UIView {
    
    private let cornerRadius: CGFloat = 15
    let width: CGFloat = 150
    let collapsedWidth: CGFloat = 40
    let height: CGFloat = 36
    
    private lazy var tuneButton: UIButton = { createButton(.tune) }()
    private lazy var headsetButton: UIButton = { createButton(.headset) }()
    private lazy var rollButton: UIButton = { createButton(.downArrow) }()
    private lazy var toggleButton: UIButton = { createButton(.leftArrow) }()
    
    private var collapsed = false
    
    private var toggleButtonLeadingConstraint: NSLayoutConstraint?
    
    var delegate: SongLyricVC!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13, *) {
            backgroundColor = .systemBackground
        }
        
        setViews()
    }
    
    func setBorder() {
        layoutIfNeeded()

        let rectShape = CAShapeLayer()
        rectShape.bounds = bounds
        rectShape.position = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        rectShape.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft , .bottomLeft], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath

        layer.mask = rectShape

        if #available(iOS 13, *) {
            let borderLayer = CAShapeLayer()
            borderLayer.path = rectShape.path
            borderLayer.lineWidth = 1
            borderLayer.strokeColor = UIColor.systemGray4.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.frame = borderLayer.bounds
            layer.addSublayer(borderLayer)
        }
    }
    
    private func setViews() {
        tuneButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2).isActive = true
        headsetButton.leadingAnchor.constraint(equalToSystemSpacingAfter: tuneButton.trailingAnchor, multiplier: 1).isActive = true
        rollButton.leadingAnchor.constraint(equalToSystemSpacingAfter: headsetButton.trailingAnchor, multiplier: 1).isActive = true
        toggleButtonLeadingConstraint = toggleButton.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: rollButton.trailingAnchor, multiplier: 1)
        toggleButtonLeadingConstraint?.isActive = true
        
        toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true

        tuneButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        headsetButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        rollButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        toggleButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        toggleButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        
    }
    
    private func createButton(_ icon: UIImage?) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(icon?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .icon
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
        addSubview(button)
        
        return button
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Handlers

extension SlidingView {
    
    @objc func buttonTapped(_ sender: UIButton) {
        if self.collapsed {
            delegate?.slideViewWidthConstraint?.constant = width
        } else {
            toggleButtonLeadingConstraint?.isActive = false
            delegate?.slideViewWidthConstraint?.constant = collapsedWidth
        }
        
        delegate?.toggleSlideView(animations: {
            if self.collapsed {
                self.tuneButton.alpha = 1
                self.headsetButton.alpha = 1
                self.rollButton.alpha = 1
                self.toggleButton.transform = self.toggleButton.transform.rotated(by: .pi)
            } else {
                self.tuneButton.alpha = 0
                self.headsetButton.alpha = 0
                self.rollButton.alpha = 0
                self.toggleButton.transform = .identity
            }
        }) {
            self.collapsed = !self.collapsed
            
            if !self.collapsed {
                self.toggleButtonLeadingConstraint?.isActive = true
            }
        }
    }
}
