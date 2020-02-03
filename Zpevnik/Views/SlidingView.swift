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
    var width: CGFloat {
        return collapsed ? 40 : (autoScrolling ? 210 : 150)
    }
    let height: CGFloat = 36
    
    private lazy var tuneButton: UIButton = { createButton(.tune) }()
    private lazy var headsetButton: UIButton = { createButton(.headset) }()
    private lazy var rollButton: UIButton = { createButton(.downArrow) }()
    private lazy var subSpeedButton: UIButton = { createButton(.remove) }()
    private lazy var addSpeedButton: UIButton = { createButton(.add) }()
    private lazy var toggleButton: UIButton = {
        let button = createButton(.leftArrow)
        
        button.transform = collapsed ? .identity : self.toggleButton.transform.rotated(by: .pi)
        
        return button
    }()
    private let rollView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private var collapsed = true
    var autoScrolling = false {
        didSet {
            setScrollSpeedButtons()
        }
    }
    
    private var toggleButtonLeadingConstraint: NSLayoutConstraint?
    private var rollButtonTrailingConstraint: NSLayoutConstraint?
    private var asfddfjka: NSLayoutConstraint?
    
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
        headsetButton.isEnabled = delegate?.songLyricHasSupportedExternals() ?? false
        rollButton.isEnabled = delegate?.canScroll() ?? false
        subSpeedButton.isEnabled = delegate?.canChangeSpeed(add: false) ?? false
        addSpeedButton.isEnabled = delegate?.canChangeSpeed(add: true) ?? false
    }
    
    private func setViews() {
        tuneButton.alpha = collapsed ? 0 : 1
        headsetButton.alpha = collapsed ? 0 : 1
        rollButton.alpha = collapsed ? 0 : 1
        
        rollView.addSubview(rollButton)
        
        rollButton.topAnchor.constraint(equalTo: rollView.topAnchor).isActive = true
        rollButton.bottomAnchor.constraint(equalTo: rollView.bottomAnchor).isActive = true
        
        rollButton.leadingAnchor.constraint(equalTo: rollView.leadingAnchor).isActive = true
        rollButtonTrailingConstraint = rollButton.trailingAnchor.constraint(equalTo: rollView.trailingAnchor)
        rollButtonTrailingConstraint?.isActive = !autoScrolling
        
        subSpeedButton.alpha = autoScrolling ? 1 : 0
        addSpeedButton.alpha = autoScrolling ? 1 : 0
        rollView.addSubview(subSpeedButton)
        rollView.addSubview(addSpeedButton)
        
        subSpeedButton.topAnchor.constraint(equalTo: rollView.topAnchor).isActive = true
        subSpeedButton.bottomAnchor.constraint(equalTo: rollView.bottomAnchor).isActive = true
        addSpeedButton.topAnchor.constraint(equalTo: rollView.topAnchor).isActive = true
        addSpeedButton.bottomAnchor.constraint(equalTo: rollView.bottomAnchor).isActive = true
        
        subSpeedButton.leadingAnchor.constraint(equalToSystemSpacingAfter: rollButton.trailingAnchor, multiplier: 1).isActive = true
        addSpeedButton.leadingAnchor.constraint(equalToSystemSpacingAfter: subSpeedButton.trailingAnchor, multiplier: 1).isActive = true
        asfddfjka = addSpeedButton.trailingAnchor.constraint(equalTo: rollView.trailingAnchor)
        asfddfjka?.isActive = autoScrolling
        
        addSubview(tuneButton)
        addSubview(headsetButton)
        addSubview(rollView)
        addSubview(toggleButton)
        
        tuneButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 2).isActive = true
        headsetButton.leadingAnchor.constraint(equalToSystemSpacingAfter: tuneButton.trailingAnchor, multiplier: 1).isActive = true
        rollView.leadingAnchor.constraint(equalToSystemSpacingAfter: headsetButton.trailingAnchor, multiplier: 1).isActive = true
        toggleButtonLeadingConstraint = toggleButton.leadingAnchor.constraint(greaterThanOrEqualToSystemSpacingAfter: rollView.trailingAnchor, multiplier: 1)
        toggleButtonLeadingConstraint?.isActive = !collapsed
        
        toggleButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4).isActive = true

        tuneButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        headsetButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        rollView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        toggleButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        toggleButton.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
    }
    
    private func setScrollSpeedButtons() {
        UIView.animate(withDuration: 0.3) {
            self.subSpeedButton.alpha = self.autoScrolling ? 1 : 0
            self.addSpeedButton.alpha = self.autoScrolling ? 1 : 0
        }
        
        if autoScrolling {
            rollButtonTrailingConstraint?.isActive = false
            asfddfjka?.isActive = true
        } else {
            asfddfjka?.isActive = false
            rollButtonTrailingConstraint?.isActive = true
        }
    }
    
    private func createButton(_ icon: UIImage?) -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setImage(icon?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = .icon
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        
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
        } else if sender == subSpeedButton {
            delegate?.changeSpeed(add: false)
        } else if sender == addSpeedButton {
            delegate?.changeSpeed(add: true)
        } else if sender == toggleButton {
            toggle()
        }
    }
    
    private func toggle() {
        if !collapsed {
            toggleButtonLeadingConstraint?.isActive = false
        }
        
        collapsed = !collapsed
        
        delegate?.toggleSlideView(animations: {
            if self.collapsed {
                self.tuneButton.alpha = 0
                self.headsetButton.alpha = 0
                self.rollButton.alpha = 0
                self.toggleButton.transform = .identity
            } else {
                self.tuneButton.alpha = 1
                self.headsetButton.alpha = 1
                self.rollButton.alpha = 1
                self.toggleButton.transform = self.toggleButton.transform.rotated(by: .pi)
            }
        }) {
            if !self.collapsed {
                self.toggleButtonLeadingConstraint?.isActive = true
            }
        }
    }
}
