//
//  ViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 03/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    internal let halfViewPresentationManager = HalfViewPresentationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
        }
    }
    
    func presentModally(_ viewController: UIViewController, animated: Bool) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            viewController.transitioningDelegate = halfViewPresentationManager
            viewController.modalPresentationStyle = .custom
        } else {
            viewController.modalPresentationStyle = .formSheet
        }
        
        present(viewController, animated: true)
    }
}
