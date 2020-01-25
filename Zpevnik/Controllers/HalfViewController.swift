//
//  HalfViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class HalfViewController: ViewController {
    
    private let cornerRadius: CGFloat = 20

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = view.bounds
        rectShape.position = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
        rectShape.path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath

        view.layer.mask = rectShape
    }
}
