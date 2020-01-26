//
//  UserViewVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 03/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class UserViewVC: SearchViewVC {
    
    private lazy var userCell: UserCell = {
        let userCell = UserCell()
        userCell.translatesAutoresizingMaskIntoConstraints = false
        
        userCell.delegate = self
        
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

// MARK: - UserCellDelegate

extension UserViewVC: UserCellDelegate {
    
    func showUserMenu() {
        halfViewPresentationManager.heightMultiplier = 325 / view.frame.height
        
        let userMenuVc = UserMenuVC()
        userMenuVc.delegate = self
        userMenuVc.user = user
        
        presentModally(userMenuVc, animated: true)
    }
}

// MARK: - UserMenuDelegate

extension UserViewVC: UserMenuDelegate {
    
    func presentViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
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
