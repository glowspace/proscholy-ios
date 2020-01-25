//
//  AppDelegate.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var restrictRotation: UIInterfaceOrientationMask = .portrait

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        
        UserSettings.load()
        
        let defaults = UserDefaults.standard
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        if let version = defaults.string(forKey: "version"), version == currentVersion { } else {
            defaults.removeObject(forKey: "lastUpdate")
            defaults.removeObject(forKey: "defaultDataLoaded")
            defaults.set(currentVersion, forKey: "version")
        }
        
        window?.rootViewController = LaunchVC()
        
        UINavigationBar.appearance().tintColor = .icon
        
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.isIdleTimerDisabled = UserSettings.blockAutoLock
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func applicationWillTerminate(_ application: UIApplication) {
        PersistenceService.saveContext()
        
        UserSettings.save()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.restrictRotation
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        print(userActivity.userInfo)
        
        return false
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
}

// MARK: - Handling universal links

//extension AppDelegate {
//
//    private func openView() {
//        let navigationController = UINavigationController()
//        let tabBarController = TabBarController()
//        let songLyricVC = SongLyricVC()
//
//        songLyricVC.dataSource = SongLyricDataSource("")
//        songLyricVC.dataSource.showAll() { }
//        songLyricVC.dataSource.currentSongLyricIndex = 0
//
//        navigationController.pushViewController(tabBarController, animated: true)
//        navigationController.pushViewController(songLyricVC, animated: true)
//
//        window?.rootViewController = navigationController
//    }
//}

// MARK: - GIDSignInDelegate

extension AppDelegate: GIDSignInDelegate {
    
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
