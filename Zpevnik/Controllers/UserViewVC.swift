//
//  UserViewVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 03/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn

class UserViewVC: SearchViewVC {
    
//    let googleSignInButton: GIDSignInButton = {
//        let button = GIDSignInButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        
//        button.style = .iconOnly
////        if #available(iOS 13, *) {
////            button.backgroundColor = .systemBackground
////        }
//        
//        return button
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        GIDSignIn.sharedInstance()?.presentingViewController = self
//        GIDSignIn.sharedInstance().signIn()
//
//        view.addSubview(googleSignInButton)
//
//        googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        googleSignInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
