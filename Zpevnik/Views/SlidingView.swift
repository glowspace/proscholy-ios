//
//  SlidingView.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 22/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SlidingView: UIView {
    
    private let cornerRadius: CGFloat = 18
    let width: CGFloat = 150
    let collapsedWidth: CGFloat = 40
    let height: CGFloat = 36
    
    private lazy var tuneButton: UIButton = { createButton(.tune) }()
    private lazy var headsetButton: UIButton = { createButton(.headset) }()
    private lazy var rollButton: UIButton = { createButton(.downArrow) }()
    private lazy var toggleButton: UIButton = {
        let button = createButton(.leftArrow)
        
        button.transform = collapsed ? .identity : self.toggleButton.transform.rotated(by: .pi)
        
        return button
    }()
    
    var collapsed = true
    
    private var toggleButtonLeadingConstraint: NSLayoutConstraint?
    
    var delegate: SlideViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13, *) {
            backgroundColor = .systemBackground
        } else {
            backgroundColor = .white
        }
        
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        layer.borderColor = UIColor.gray4.cgColor
        layer.borderWidth = 1
        
        setViews()
    }
    
    func shouldUpdateButtonsState() {
        headsetButton.isEnabled = delegate?.songLyricHasSupportedExternals() ?? true
        rollButton.isEnabled = !(delegate?.canScroll() ?? false)
    }
    
    private func setViews() {
        tuneButton.alpha = collapsed ? 0 : 1
        headsetButton.alpha = collapsed ? 0 : 1
        rollButton.alpha = collapsed ? 0 : 1
        
        tuneButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2).isActive = true
        headsetButton.leadingAnchor.constraint(equalToSystemSpacingAfter: tuneButton.trailingAnchor, multiplier: 1).isActive = true
        rollButton.leadingAnchor.constraint(equalToSystemSpacingAfter: headsetButton.trailingAnchor, multiplier: 1).isActive = true
        toggleButtonLeadingConstraint = toggleButton.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: rollButton.trailingAnchor, multiplier: 1)
        toggleButtonLeadingConstraint?.isActive = !collapsed
        
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
        if sender == tuneButton {
            delegate?.showTuneOptions()
        } else if sender == headsetButton {
            delegate?.showExternals()
        } else if sender == rollButton {
            delegate?.toggleAutoScroll() { isAutoScrolling in
                self.rollButton.setImage(isAutoScrolling ? UIImage.stop?.withRenderingMode(.alwaysTemplate) : UIImage.downArrow?.withRenderingMode(.alwaysTemplate), for: .normal)
            }
        } else if sender == toggleButton {
            toggle()
        }
    }
    
    private func toggle() {
        if !collapsed {
            toggleButtonLeadingConstraint?.isActive = false
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
