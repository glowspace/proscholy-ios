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
    static var fontSize: Float = 17.0 {
        didSet {
            fontSize = min(max(fontSize, Constants.minFontSize), Constants.maxFontSize)
        }
    }
    static var darkMode = false {
        didSet {
            prepareDarkMode(darkMode)
        }
    }
    static var showBottomOptions = false
    
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
            fontSize = defaults.float(forKey: "fontSize")
        }
        
        if defaults.object(forKey: "darkMode") != nil {
            darkMode = defaults.bool(forKey: "darkMode")
        }
        if defaults.object(forKey: "showBottomOptions") != nil {
            showBottomOptions = defaults.bool(forKey: "showBottomOptions")
        }
    }
    
    static func save() {
        let defaults = UserDefaults.standard
        
        defaults.set(blockAutoLock, forKey: "blockAutoLock")
        defaults.set(serif, forKey: "serif")
        defaults.set(showSliders, forKey: "showSliders")
        defaults.set(showChords, forKey: "showChords")
        defaults.set(fontSize, forKey: "fontSize")
        defaults.set(darkMode, forKey: "darkMode")
        defaults.set(showBottomOptions, forKey: "showBottomOptions")
    }
    
    private static func prepareDarkMode(_ darkMode: Bool) {
        UINavigationBar.appearance().barTintColor = Constants.getMiddleColor()
        UITabBar.appearance().barTintColor = Constants.getMiddleColor()
        
        UITableView.appearance().backgroundColor = Constants.getDarkColor() ?? .groupTableViewBackground
        UITableView.appearance().separatorColor = Constants.getLightColor()
        UITableViewCell.appearance().backgroundColor = Constants.getTableViewCellColor() ?? .white

        UICollectionViewCell.appearance().backgroundColor = Constants.getMiddleColor() ?? .white

        UITextView.appearance().backgroundColor = Constants.getDarkColor()
        UITextView.appearance().textColor = darkMode ? .white : .black

        UILabel.appearance().darkMode = darkMode

        SearchView.appearance().backgroundColor = Constants.getMiddleColor() ?? .white

        UITextField.appearance().textColor = darkMode ? .white : .black
    }
}
