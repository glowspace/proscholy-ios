//
//  UserSettingsService.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 04/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class UserSettings {
    
    private init() { }
    
    static var blockAutoLock = false {
        didSet {
            UIApplication.shared.isIdleTimerDisabled = blockAutoLock
        }
    }
    static var showChords = true
    static var fontSize: CGFloat = 17.0 {
        didSet {
            fontSize = min(max(fontSize, Constants.minFontSize), Constants.maxFontSize)
        }
    }
    static var showBottomOptions = true
    
    static var favoriteOrderLast = 0
    
    static var scrollSpeed = 3
    
    static func load() {
        let defaults = UserDefaults.standard
        
        blockAutoLock = loadObject(forKey: "blockAutoLock", defaults: defaults) ?? blockAutoLock
        showChords = loadObject(forKey: "showChords", defaults: defaults) ?? showChords
        fontSize = loadObject(forKey: "fontSize", defaults: defaults) ?? fontSize
        showBottomOptions = loadObject(forKey: "showBottomOptions", defaults: defaults) ?? showBottomOptions
        scrollSpeed = loadObject(forKey: "scrollSpeed", defaults: defaults) ?? scrollSpeed
    }
    
    static func loadObject<T>(forKey key: String, defaults: UserDefaults) -> T? {
        return defaults.object(forKey: key) as? T
    }
    
    static func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(blockAutoLock, forKey: "blockAutoLock")
        defaults.set(showChords, forKey: "showChords")
        defaults.set(fontSize, forKey: "fontSize")
        defaults.set(showBottomOptions, forKey: "showBottomOptions")
        defaults.set(scrollSpeed, forKey: "scrollSpeed")
    }
}
