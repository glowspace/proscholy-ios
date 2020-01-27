//
//  HalfViewPresentationController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 05/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class HalfViewPresentationController: UIPresentationController {
    
    private let defaultDimmingAlpha: CGFloat = 0.5
    private let expandedScale: CGFloat = 0.9
    private let expandedCornerRadius: CGFloat = 10
    private let expandedTopSpace: CGFloat = 30
    private let handleSize: CGFloat = 14
    
    private let heightMultiplier: CGFloat
    private let canBeExpanded: Bool
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .black
        view.alpha = 0.0
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))
        
        return view
    }()
    
    private var startingYLocation: CGFloat!
    
    private var currentState: HalfViewState {
        willSet {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.1, options: [], animations: {
                switch(newValue) {
                case .normal:
                    self.presentedView?.frame.origin.y = (self.containerView?.frame.height ?? 1) * (1 - self.heightMultiplier) - self.handleSize
                case .expanded:
                    self.presentedView?.frame.origin.y = self.expandedTopSpace
                }
            })
                
            UIView.animate(withDuration: 0.3) {
                switch(newValue) {
                case .normal:
                    self.dimmingView.alpha = self.defaultDimmingAlpha
                    self.presentingViewController.view.transform = CGAffineTransform.identity //.scaledBy(x: 1, y: 1)
                    self.presentingViewController.view.layer.cornerRadius = 0
                case .expanded:
                    self.dimmingView.alpha = 0
                    self.presentingViewController.view.transform = CGAffineTransform.identity.scaledBy(x: self.expandedScale, y: self.expandedScale)
                    self.presentingViewController.view.layer.cornerRadius = self.expandedCornerRadius
                }
            }
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        var frame: CGRect = .zero
        
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView.bounds.size)
        frame.origin.y = containerView.frame.height * (1 - heightMultiplier) - handleSize
        
        return frame
    }
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, heightMultiplier: CGFloat, canBeExpanded: Bool) {
        self.heightMultiplier = heightMultiplier
        self.canBeExpanded = canBeExpanded
        
        currentState = .normal
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        setGestureRecognizers()
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        containerView?.insertSubview(dimmingView, at: 0)

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", metrics: nil, views: ["dimmingView": dimmingView]))

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = defaultDimmingAlpha
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = self.defaultDimmingAlpha
        })
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 0.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: parentSize.height)
    }
}

private extension HalfViewPresentationController {
    
    func setGestureRecognizers() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        
        pan.delaysTouchesBegan = false
        pan.delaysTouchesEnded = false
        
        presentedView?.addGestureRecognizer(pan)
    }
    
    func dimmingAlpha(_ value: CGFloat) -> CGFloat {
        guard let containerView = containerView else {
            return defaultDimmingAlpha
        }

        let expandedPosition: CGFloat = expandedTopSpace
        let normalPosition = containerView.frame.height * (1 - heightMultiplier) - handleSize
        let hiddenPostion = containerView.frame.height
        let normalHeight = hiddenPostion - normalPosition

        if value >= hiddenPostion || value <= expandedPosition {
            return 0
        }

        if value < normalPosition {
            return defaultDimmingAlpha * (1 - ((normalPosition - value) / (normalPosition - expandedPosition)))
        }

        return defaultDimmingAlpha * (1 - ((value - normalPosition) / normalHeight))
    }

    func scalePresentingView(_ value: CGFloat) -> CGFloat {
        guard let containerView = containerView else {
            return 1
        }

        let expandedPosition: CGFloat = expandedTopSpace
        let normalPosition = containerView.frame.height * (1 - heightMultiplier) - handleSize

        if value >= normalPosition {
            return 1
        }

        return 1 - (1 - expandedScale) * ((normalPosition - value) / (normalPosition - expandedPosition))
    }
    
    func presentingViewCornerRadius(_ value: CGFloat) -> CGFloat {
        guard let containerView = containerView else {
            return 0
        }

        let expandedPosition: CGFloat = expandedTopSpace
        let normalPosition = containerView.frame.height * (1 - heightMultiplier) - handleSize

        if value >= normalPosition {
            return 0
        }

        return expandedCornerRadius * ((normalPosition - value) / (normalPosition - expandedPosition))
    }
    
    private func updatePresentedViewPosition(_ y: CGFloat) {
        let presentedY = presentedView?.frame.origin.y ?? 0
        let scale = scalePresentingView(presentedY)
        
        dimmingView.alpha = dimmingAlpha(presentedY)
        if canBeExpanded {
            presentingViewController.view.transform = CGAffineTransform.identity.scaledBy(x: scale, y: scale)
            presentingViewController.view.layer.cornerRadius = presentingViewCornerRadius(presentedY)
        }
        
        // make dragging slower when above normal height if can't be expanded
        let dragSpeedMultiplier: CGFloat = canBeExpanded ? 1 : 0.1
        
        if canBeExpanded && startingYLocation + y < expandedTopSpace {
            let newY = expandedTopSpace - 0.05 * ((expandedTopSpace - (startingYLocation + y)))
            if newY > (containerView?.safeAreaInsets.top ?? 0) - handleSize {
                // make dragging slower when above expanded height
                presentedView?.frame.origin.y = newY
            }
        } else if startingYLocation + y > startingYLocation {
            presentedView?.frame.origin.y = startingYLocation + y
        } else {
            presentedView?.frame.origin.y = startingYLocation + dragSpeedMultiplier * y
        }
    }
    
    @objc func didPan(_ panRecognizer: UIPanGestureRecognizer) {
        let translation = panRecognizer.translation(in: presentedView)
        let velocity = panRecognizer.velocity(in: presentedView)
        
        switch panRecognizer.state {
        case .began:
            startingYLocation = presentedView?.frame.minY ?? 0
        case .changed :
            updatePresentedViewPosition(translation.y)
        case .ended :
            if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height, let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                if abs(velocity.y) > 500 {
                    if velocity.y < 0 {
                        if canBeExpanded && currentState == .normal && (velocity.y < -1500 || translation.y < 0) {
                            currentState = .expanded
                        } else {
                            currentState = .normal
                        }
                    } else if velocity.y > 0 {
                        if currentState == .expanded  {
                            currentState = .normal
                        } else if velocity.y > 1500 || translation.y > 0 {
                            dismiss()
                        } else {
                            currentState = .normal
                        }
                    }
                } else {
                    if canBeExpanded && (presentedView?.frame.origin.y ?? 0) < (safeAreaHeight + bottomPadding + handleSize) * 0.25 {
                        currentState = .expanded
                    } else if (presentedView?.frame.origin.y ?? 0) < safeAreaHeight - 100 - handleSize {
                        currentState = .normal
                    } else {
                        dismiss()
                    }
                }
            }
        default: break
        }
    }
    
    @objc func dismiss() {
        if let halfViewController = self.presentedViewController as? HalfViewController {
            halfViewController.screenshotVC?.screenshottedVC?.view.isHidden = false
            presentedViewController.dismiss(animated: true) {
                halfViewController.screenshotVC?.dismiss(animated: false)
            }
        } else {
            presentedViewController.dismiss(animated: true)
        }
    }
}
