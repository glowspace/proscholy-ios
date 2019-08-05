//
//  GradientView.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 03/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class GradientView: UIView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        alpha = 0.75
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        for touch in touches {
            let location = touch.location(in: self)
            if location.x < 0 || location.x > bounds.width || location.y < 0 || location.y > bounds.height {
                alpha = 1.0
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        alpha = 1.0
    }
    
    var gradientLayer: CAGradientLayer? {
        didSet {
            if let gradientLayer = gradientLayer {
                layer.insertSublayer(gradientLayer, at: 0)
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        gradientLayer?.frame = rect
        
        alpha = 1.0
    }
    
}
