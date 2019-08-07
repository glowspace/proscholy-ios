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
    
    static let minFontSize: Float = 10
    static let maxFontSize: Float = 45
    
    static let serifFont = "Times new roman"
    static let sansSerifFont = "Helvetica"
    
    static func getLightColor(_ darkMode: Bool) -> UIColor? { return darkMode ? .darkGray : nil }
    static func getMiddleColor(_ darkMode: Bool) -> UIColor? { return darkMode ? UIColor(white: 0.15, alpha: 1) : nil }
    static func getDarkColor(_ darkMode: Bool) -> UIColor? { return darkMode ? UIColor(white: 0.05, alpha: 1) : nil }
    
    static let songsUpdateInterval: Double = 3600 * 24
}
