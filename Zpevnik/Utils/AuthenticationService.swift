//
//  FirebaseService.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 21/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import Firebase
import GoogleSignIn

class AuthenticationService: NSObject {
    
    override init() {
        super.init()
    }
    
    func prepare() {
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
    }
}

// MARK: - Google sign in

extension AuthenticationService: GIDSignInDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else { return }
        
        guard let authentication = user.authentication else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print(error)
                return
            }
            
            let currentUser = Auth.auth().currentUser
            currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error {
                    print(error)
                    return;
                }
                
                print(idToken)
            }
        }
    }
}
