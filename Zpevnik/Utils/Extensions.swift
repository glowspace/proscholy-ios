//
//  Extensions.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        navigationController?.navigationBar.endEditing(true)
    }
}

extension UITextField {
    
    func updateFontSize() {
        self.layoutIfNeeded()
        
        if let placeholder = self.placeholder {
            var fontSize: CGFloat = 25
            while true {
                if (placeholder as NSString).size(withAttributes: [.font: UIFont.systemFont(ofSize: fontSize)]).width < self.frame.size.width - 60 {
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
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
}

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
}

extension UIViewController {
    
    func hideBars(_ hidden: Bool, animated: Bool) {
        guard let tabBarController = tabBarController else { return }
        guard let navigationController = navigationController else { return }
        
        if !hidden {
            tabBarController.tabBar.isHidden = hidden
            navigationController.navigationBar.isHidden = hidden
        }
        
        let duration = animated ? 0.3 : 0
        UIView.animate(withDuration: duration, animations: {
            tabBarController.tabBar.frame.origin.y += tabBarController.tabBar.frame.height * (hidden ? 1 : -1)
            navigationController.navigationBar.frame.origin.y -= navigationController.navigationBar.frame.height * (hidden ? 1 : -1)
            
            self.view.frame.origin.y -= navigationController.navigationBar.frame.height * (hidden ? 1 : -1)
            if hidden {
                self.view.frame.size.height += tabBarController.tabBar.frame.height
            }
        }) { _ in
            if !hidden {
                self.view.frame.size.height -= tabBarController.tabBar.frame.height
            }
        
            tabBarController.tabBar.isHidden = hidden
            navigationController.navigationBar.isHidden = hidden
        }
    }
}
