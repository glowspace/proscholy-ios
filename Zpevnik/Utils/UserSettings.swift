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
    static var fontSize: Float = 17.0 {
        didSet {
            fontSize = min(max(fontSize, Constants.minFontSize), Constants.maxFontSize)
        }
    }
    static var darkMode = false
    
    
    static func load() {
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "blockAutoLock") != nil {
            blockAutoLock = defaults.bool(forKey: "blockAutoLock")
        }
        
        if defaults.object(forKey: "showChords") != nil {
            showChords = defaults.bool(forKey: "showChords")
        }
        
        if defaults.object(forKey: "fontSize") != nil {
            fontSize = defaults.float(forKey: "fontSize")
        }
        
        if defaults.object(forKey: "darkMode") != nil {
            darkMode = defaults.bool(forKey: "darkMode")
        }
    }
    
    static func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(blockAutoLock, forKey: "blockAutoLock")
        defaults.set(showChords, forKey: "showChords")
        defaults.set(fontSize, forKey: "fontSize")
        defaults.set(darkMode, forKey: "darkMode")
        
    }
}
