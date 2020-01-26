//
//  Slider.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 04/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import QuartzCore

class Slider: UIControl {
    
    let minimumValue: Float
    let maximumValue: Float
    var currentValue: Float
    
    var trackTintColor: UIColor
    var trackHighlightTintColor: UIColor
    var thumbTintColor: UIColor
    
    var curvaceousness : CGFloat = 1.0
    
    let trackLayer = SliderTrackLayer()
    let thumbLayer = SliderThumbLayer()
    
    var previousLocation = CGPoint()
    
    var thumbWidth: CGFloat {
        return bounds.height
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        updateLayerFrames()
    }
    
    // MARK: - Touch handlers
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        previousLocation = touch.location(in: self)
        
        if thumbLayer.frame.contains(previousLocation) {
            thumbLayer.highlighted = true
        }
        
        return thumbLayer.highlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)
        let location = touch.location(in: self)
        
        let deltaLocation = Float(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Float(bounds.width - thumbWidth)
        
        previousLocation = location
        
        if thumbLayer.highlighted {
            currentValue += deltaValue
            currentValue = boundValue()
        }
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        updateLayerFrames()
        
        CATransaction.commit()
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        thumbLayer.highlighted = false
        thumbLayer.displayIfNeeded()
    }
    
    // MARK: - Initializers
    
    init(currentValue: Float, minimumValue: Float, maximumValue: Float) {
        self.currentValue = currentValue
        self.minimumValue = minimumValue
        self.maximumValue = maximumValue
        
        trackTintColor = .gray5
        thumbTintColor = .white
        trackHighlightTintColor = .blue
        
        super.init(frame: CGRect.zero)
        
        trackLayer.contentsScale = UIScreen.main.scale
        trackLayer.slider = self
        layer.addSublayer(trackLayer)
        
        thumbLayer.contentsScale = UIScreen.main.scale
        thumbLayer.slider = self
        layer.addSublayer(thumbLayer)
        
        updateLayerFrames()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Custom functions
    
    private func updateLayerFrames() {
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 2.2)
        trackLayer.setNeedsDisplay()
        
        let thumbLayerCenter = CGFloat(positionForValue())
        thumbLayer.frame = CGRect(x: thumbLayerCenter - thumbWidth / 2.0, y: 0.0, width: thumbWidth, height: thumbWidth)
        thumbLayer.setNeedsDisplay()
    }
    
    func positionForValue() -> Float {
        return Float(bounds.width - thumbWidth) * (currentValue - minimumValue) / (maximumValue - minimumValue) + Float(thumbWidth / 2.0)
    }
    
    private func boundValue() -> Float {
        return min(max(currentValue, minimumValue), maximumValue)
    }
}
