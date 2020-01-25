//
//  Extensions.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

extension UIImage {
    
    static var aboutApp: UIImage? { return UIImage(named: "aboutAppIcon") }
    static var aboutProject: UIImage? { return UIImage(named: "aboutProjectIcon") }
    static var add: UIImage? { return UIImage(named: "addIcon") }
    static var addPlaylist: UIImage? { return UIImage(named: "addPlaylistIcon") }
    static var back: UIImage? { return UIImage(named: "backIcon") }
    static var clear: UIImage? { return UIImage(named: "clearIcon") }
    static var downArrow: UIImage? { return UIImage(named: "downArrowIcon") }
    static var feedback: UIImage? { return UIImage(named: "feedbackIcon") }
    static var filter: UIImage? { return UIImage(named: "filterIcon") }
    static var headset: UIImage? { return UIImage(named: "headsetIcon") }
    static var home: UIImage? { return UIImage(named: "homeIcon") }
    static var homeFilled: UIImage? { return UIImage(named: "homeIconFilled") }
    static var leftArrow: UIImage? { return UIImage(named: "leftArrowIcon") }
    static var menu: UIImage? { return UIImage(named: "menuIcon") }
    static var more: UIImage? { return UIImage(named: "moreIcon") }
    static var musicNotes: UIImage? { return UIImage(named: "musicNotesIcon") }
    static var person: UIImage? { return UIImage(named: "personIcon") }
    static var personFilled: UIImage? { return UIImage(named: "personIconFilled") }
    static var rightArrow: UIImage? { return UIImage(named: "rightArrowIcon") }
    static var search: UIImage? { return UIImage(named: "searchIcon") }
    static var selectAll: UIImage? { return UIImage(named: "selectAllIcon") }
    static var settings: UIImage? { return UIImage(named: "settingsIcon") }
    static var share: UIImage? { return UIImage(named: "shareIcon") }
    static var songBook: UIImage? { return UIImage(named: "songBookIcon") }
    static var star: UIImage? { return UIImage(named: "starIcon") }
    static var starFilled: UIImage? { return UIImage(named: "starIconFilled") }
    static var stop: UIImage? { return UIImage(named: "stopIcon") }
    static var translate: UIImage? { return UIImage(named: "translateIcon") }
    static var tune: UIImage? { return UIImage(named: "tuneIcon") }
    static var warning: UIImage? { return UIImage(named: "warningIcon" )}
    static var web: UIImage? { return UIImage(named: "webIcon") }
}

extension UIColor {
    
    static var blue: UIColor { return UIColor(named: "blue") ?? .systemBlue }
    static var green: UIColor { return UIColor(named: "green") ?? .systemGreen }
    static var icon: UIColor { return UIColor(named: "icon") ?? .gray }
    static var inverted: UIColor { return UIColor(named: "inverted") ?? .black }
    static var red: UIColor { return UIColor(named: "red") ?? .systemRed }
    static var spotifyGreen: UIColor { return UIColor(named: "spotifyGreen") ?? .systemGreen }
    static var yellow: UIColor { return UIColor(named: "yellow") ?? .systemYellow }
    
}

extension UITableView {
    
    func scrollToTop() {
        showsVerticalScrollIndicator = false
        scrollToRow(at: IndexPath(row: NSNotFound, section: 0), at: .top, animated: true)
        showsVerticalScrollIndicator = true
    }
}

extension UITabBarController {
    
    func setTabBarHidden(_ hidden: Bool, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.3 : 0, animations: {
            // + 1 to hide border
            self.tabBar.frame.origin.y += (self.tabBar.frame.height + 1) * (hidden ? 1 : -1)
        })
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}

extension NSRegularExpression {
    
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}



// MARK: - OLD

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    static func from(hex: String?) -> UIColor {
        let hex = hex ?? "#303F9F"
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if(cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if(cString.count != 6) {
            return .red
        }

        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)

        return UIColor(red: Int((rgbValue & 0xFF0000) >> 16), green: Int((rgbValue & 0x00FF00) >> 8), blue: Int(rgbValue & 0x0000FF))
    }
}

extension UITextField {
    
    func updateFontSize() {
        self.layoutIfNeeded()
        
        if let placeholder = self.placeholder {
            var fontSize: CGFloat = self.font?.pointSize ?? 20
            
            while true {
                let font = UIFont.systemFont(ofSize: fontSize)
                if (placeholder as NSString).size(withAttributes: [.font: font]).width < frame.size.width {
                    self.font = font
                    break
                }
                
                fontSize -= 1
                if fontSize == 0 {
                    break
                }
            }
        }
    }
}

class TableViewCell: UITableViewCell {
    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
        
//        if #available(iOS 13, *) { } else {
//            selectedBackgroundView?.backgroundColor = Constants.getMiddleColor() ?? UIColor(white: 0.85, alpha: 1)
//        }
//    }
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        selectedBackgroundView = UIView()
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
}
