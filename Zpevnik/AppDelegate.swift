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
        
//        AuthenticationService().prepare()
        
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
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
}
