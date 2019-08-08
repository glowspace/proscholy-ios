//
//  Extensions.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    static func from(hex: String?) -> UIColor {
        guard let hex = hex else { return .red }
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

extension UIFont {
    
    static func getFont(ofSize size: CGFloat, weight: UIFont.Weight? = nil) -> UIFont {
//        if UserSettings.serif, let font = UIFont(name: Constants.serifFont, size: size) {
//            return font
//        } else if let font = UIFont(name: Constants.sansSerifFont, size: size) {
//            return font
//        }

        return .systemFont(ofSize: size)
    }
}

extension UILabel {
    
    @objc var darkMode: Bool {
        get {
            return false
        }
        set(darkMode) {
            if let text = text, ["Domů", "Zpěvníky", "Oblíbené", "Ostatní"].contains(text) {
                return
            }
            if darkMode {
                textColor = .white
            } else {
                textColor = .black
            }
        }
    }
    
    @objc var substituteFontName: String {
        get {
            return ""
        }
        set {
            font = UIFont.getFont(ofSize: font.pointSize)
        }
    }
}

class NavigationController : UINavigationController {
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UserSettings.darkMode ? .lightContent : .default
    }
}

class ViewController: UIViewController {

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UserSettings.darkMode ? .lightContent : .default
    }
}

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        navigationController?.navigationBar.endEditing(true)
    }
    
    func setTitle(_ title: String?, iconImage: UIImage? = nil) {
        let view = UIView()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.75
        label.textAlignment = .center
        
        view.addSubview(label)
        if iconImage != nil {
            let icon = UIImageView(image: iconImage)
            icon.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(icon)
            
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[icon(==40)]-[label]-|", metrics: nil, views: ["icon": icon, "label": label]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[icon(==40)]|", options: [.alignAllCenterY], metrics: nil, views: ["icon": icon, "label": label]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [.alignAllCenterY], metrics: nil, views: ["icon": icon, "label": label]))
        } else {
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", metrics: nil, views: ["label": label]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [.alignAllCenterY], metrics: nil, views: ["label": label]))
        }
        
        navigationItem.titleView = view
        navigationItem.title = ""
    }
}

extension UITextField {
    
    func updateFontSize() {
        self.layoutIfNeeded()
        
        if let placeholder = self.placeholder {
            var fontSize: CGFloat = 25
            while true {
                
                if (placeholder as NSString).size(withAttributes: [.font: UIFont.getFont(ofSize: fontSize)]).width < self.frame.size.width - 60 {
                    self.adjustsFontSizeToFitWidth = true
                    self.minimumFontSize = fontSize
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

class TextField: UITextField {
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        if let clearButton = value(forKey: "_clearButton") as? UIButton {
            let templateImage = clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
            clearButton.setImage(templateImage, for: .normal)
            clearButton.tintColor = UserSettings.darkMode ? .white : .black
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let placeholderLabel = value(forKey: "placeholderLabel") as? UILabel {
            placeholderLabel.textColor = .lightGray
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        keyboardAppearance = UserSettings.darkMode ? .dark : .default
    }
}

class PaddingLabel: UILabel {
    
    var topInset: CGFloat = 0
    var rightInset: CGFloat = 0
    var bottomInset: CGFloat = 0
    var leftInset: CGFloat = 0
    
    func setInsets(top: CGFloat? = nil, right: CGFloat? = nil, bottom: CGFloat? = nil, left: CGFloat? = nil) {
        topInset = top ?? 0
        rightInset = right ?? 0
        bottomInset = bottom ?? 0
        leftInset = left ?? 0
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = super.sizeThatFits(size)
        return CGSize(width: size.width + rightInset + leftInset, height: size.height + topInset + bottomInset)
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
}

class TableViewCell: UITableViewCell {
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        backgroundColor = highlighted ? (Constants.getMiddleColor() ?? UIColor(white: 0.85, alpha: 1)) : (Constants.getTableViewCellColor() ?? .white)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        backgroundColor = selected ? (Constants.getMiddleColor() ?? UIColor(white: 0.85, alpha: 1)) : (Constants.getTableViewCellColor() ?? .white)
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
