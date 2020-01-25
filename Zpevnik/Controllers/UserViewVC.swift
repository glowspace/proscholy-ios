//
//  UserViewVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 03/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class UserViewVC: SearchViewVC {
    
    private let user: User? = User.createFromDict(["id": "1", "name": "Patrik Dobiáš", "email": "patrikdobidobias@gmail.com"], PersistenceService.backgroundContext)
    
    private let userCell: UserCell = {
        let userCell = UserCell()
        userCell.translatesAutoresizingMaskIntoConstraints = false
        
        return userCell
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userCell.userName = user?.name ?? "Nepřihlášený uživatel"
        
        setViews()
    }
    
    private func setViews() {
        view.addSubview(userCell)
        
        userCell.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        userCell.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        userCell.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        userCell.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
}

//import Firebase
//import GoogleSignIn

//class UserViewVC: SearchViewVC {
//
//    let googleSignInButton: GIDSignInButton = {
//        let button = GIDSignInButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//
//        button.style = .iconOnly
//
//        return button
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        GIDSignIn.sharedInstance()?.presentingViewController = self
//
//        let currentUser = Auth.auth().currentUser
//        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
//            if let error = error {
//                print(error)
//                return;
//            }
//
//            print(idToken)
//        }
//
//        view.addSubview(googleSignInButton)
//
//        googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        googleSignInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//    }
//}
