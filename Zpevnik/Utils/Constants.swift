//
//  Constants.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 04/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class Constants {
    
    private init() { }
    
    static let minFontSize: CGFloat = 10
    static let maxFontSize: CGFloat = 40
    
    static let serifFont = "Courier"
    static let sansSerifFont = "Chalkduster"
    
    @available(iOS 12.0, *)
    static func getLightColor(_ darkMode: UIUserInterfaceStyle) -> UIColor? { return darkMode == .dark ? .darkGray : nil }
    @available(iOS 12.0, *)
    static func getMiddleColor(_ darkMode: UIUserInterfaceStyle) -> UIColor? { return darkMode == .dark ? UIColor(white: 0.15, alpha: 1) : nil }
    @available(iOS 12.0, *)
    static func getDarkColor(_ darkMode: UIUserInterfaceStyle) -> UIColor? { return darkMode == .dark ? UIColor(white: 0.05, alpha: 1) : nil }
    @available(iOS 12.0, *)
    static func getTableViewCellColor(_ darkMode: UIUserInterfaceStyle) -> UIColor? { return darkMode == .dark ? UIColor(white: 0.1, alpha: 1) : nil }
    
//    static func getLightColor() -> UIColor? { return UserSettings.darkMode ? .darkGray : nil }
//    static func getMiddleColor() -> UIColor? { return UserSettings.darkMode ? UIColor(white: 0.15, alpha: 1) : nil }
//    static func getDarkColor() -> UIColor? { return UserSettings.darkMode ? UIColor(white: 0.05, alpha: 1) : nil }
//    static func getTableViewCellColor() -> UIColor? { return UserSettings.darkMode ? UIColor(white: 0.1, alpha: 1) : nil }
    
    static let songsUpdateInterval: Double = 3600 * 12
}
