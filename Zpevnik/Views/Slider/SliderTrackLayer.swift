//
//  SliderTrackLayer.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 04/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SliderTrackLayer: CALayer {

    weak var slider: Slider?
    
    override func draw(in ctx: CGContext) {
        if let slider = slider {
            let cornerRadius = bounds.height * slider.curvaceousness / 2.0
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            ctx.addPath(path.cgPath)
            
            ctx.setFillColor(slider.trackTintColor.cgColor)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
            
            ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
            let currentValuePosition = CGFloat(slider.positionForValue())
            let frame = CGRect(x: 0, y: 0, width: currentValuePosition, height: bounds.height)
            let rectPath = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius)
            ctx.addPath(rectPath.cgPath)
            ctx.fillPath()
        }
    }
}
