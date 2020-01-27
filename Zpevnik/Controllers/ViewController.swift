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
    
    func presentModally(_ halfViewController: HalfViewController, animated: Bool) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            halfViewController.transitioningDelegate = halfViewPresentationManager
            halfViewController.modalPresentationStyle = .custom
            
            if halfViewPresentationManager.canBeExpanded {
                let screenShotVC = ScreenshotVC()
                screenShotVC.screenshottedVC = tabBarController
                screenShotVC.modalPresentationStyle = .overFullScreen
                
                halfViewController.screenshotVC = screenShotVC
                
                present(screenShotVC, animated: false)
                screenShotVC.present(halfViewController, animated: true) {
                    screenShotVC.screenshot = self.tabBarController?.view.screenshot()
                    self.tabBarController?.view.isHidden = true
                }
            } else {
                present(halfViewController, animated: true)
            }
        } else {
            halfViewController.modalPresentationStyle = .formSheet
            present(halfViewController, animated: true)
        }
    }
}
