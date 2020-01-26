//
//  HalfViewPresentationController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 05/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class HalfViewPresentationController: UIPresentationController {
    
    private let heightMultiplier: CGFloat
    private var dimmingView: UIView!
    
    private var startingYLocation: CGFloat!
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        
        var frame: CGRect = .zero
        
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView.bounds.size)
        frame.origin.y = containerView.frame.height * (1 - heightMultiplier)
        
        return frame
    }
    
    init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, heightMultiplier: CGFloat) {
        self.heightMultiplier = heightMultiplier
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        setViews()
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        
        presentedView?.frame = frameOfPresentedViewInContainerView
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        guard let dimmingView = dimmingView else {
          return
        }
        
        containerView?.insertSubview(dimmingView, at: 0)

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", metrics: nil, views: ["dimmingView": dimmingView]))

        guard let coordinator = presentedViewController.transitionCoordinator else {
            dimmingView.alpha = 1.0
            return
        }

        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
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
        return CGSize(width: parentSize.width, height: parentSize.height) // * heightMultiplier
    }
}

private extension HalfViewPresentationController {
    
    func setViews() {
        setDimmingView()
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPan))
        
        pan.delaysTouchesBegan = false
        pan.delaysTouchesEnded = false
        
        presentedView?.addGestureRecognizer(pan)
    }
    
    func setDimmingView() {
        dimmingView = UIView()
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.alpha = 0.0
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        dimmingView.addGestureRecognizer(tap)
    }
    
    @objc func didPan(_ panRecognizer: UIPanGestureRecognizer) {
        let translation = panRecognizer.translation(in: presentedView)
        let velocity = panRecognizer.velocity(in: presentedView)
        
        switch panRecognizer.state {
        case .began:
            startingYLocation = presentedView?.frame.minY ?? 0
        case .changed :
            if startingYLocation + translation.y > 30.0 {
                presentedView?.frame.origin.y = startingYLocation + translation.y
            }
        case .ended :
            if let safeAreaHeight = UIApplication.shared.keyWindow?.safeAreaLayoutGuide.layoutFrame.size.height { //}, let bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom {
                
                if velocity.y > 1500.0 {
                    presentingViewController.dismiss(animated: true)
                }
                
//                if (presentedView?.frame.origin.y ?? 0) < (safeAreaHeight + bottomPadding) * 0.25 {
//
//                } else
                if (presentedView?.frame.origin.y ?? 0) < (safeAreaHeight) - 70 {
                    UIView.animate(withDuration: 0.3) {
                        self.presentedView?.frame.origin.y = self.startingYLocation
                    }
                } else {
                    presentingViewController.dismiss(animated: true)
                }
            }
        default: break
        }
    }
    
    @objc func dismiss() {
        presentingViewController.dismiss(animated: true)
    }
}
