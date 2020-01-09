//
//  HalfViewPresentationManager.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 05/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class HalfViewPresentationManager: NSObject, UIViewControllerTransitioningDelegate {
    
    var heightMultiplier: CGFloat = 1.0
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfViewPresentationController(presentedViewController: presented, presenting: presenting, heightMultiplier: heightMultiplier)
    }
}
