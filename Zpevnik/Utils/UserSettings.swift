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
    static var serif = false {
        didSet {
//            UILabel.appearance().substituteFontName = ""
        }
    }
    static var showSliders = false
    static var showChords = true
    static var fontSize: CGFloat = 17.0 {
        didSet {
            fontSize = min(max(fontSize, Constants.minFontSize), Constants.maxFontSize)
        }
    }
    static var showBottomOptions = true
    
    static var favoriteOrderLast = 0
    
    static func load() {
        let defaults = UserDefaults.standard
        
        if defaults.object(forKey: "blockAutoLock") != nil {
            blockAutoLock = defaults.bool(forKey: "blockAutoLock")
        }
        
        if defaults.object(forKey: "serif") != nil {
            serif = defaults.bool(forKey: "serif")
        }
        
        if defaults.object(forKey: "showSliders") != nil {
            showSliders = defaults.bool(forKey: "showSliders")
        }
        
        if defaults.object(forKey: "showChords") != nil {
            showChords = defaults.bool(forKey: "showChords")
        }
        
        if defaults.object(forKey: "fontSize") != nil {
            fontSize = CGFloat(defaults.float(forKey: "fontSize"))
        }
        
        if defaults.object(forKey: "showBottomOptions") != nil {
            showBottomOptions = defaults.bool(forKey: "showBottomOptions")
        }
        
        if defaults.object(forKey: "favoriteOrder") != nil {
            favoriteOrderLast = defaults.integer(forKey: "favoriteOrder")
        }
    }
    
    static func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(blockAutoLock, forKey: "blockAutoLock")
        defaults.set(serif, forKey: "serif")
        defaults.set(showSliders, forKey: "showSliders")
        defaults.set(showChords, forKey: "showChords")
        defaults.set(fontSize, forKey: "fontSize")
        defaults.set(showBottomOptions, forKey: "showBottomOptions")
        defaults.set(favoriteOrderLast, forKey: "favoriteOrder")
    }
}
