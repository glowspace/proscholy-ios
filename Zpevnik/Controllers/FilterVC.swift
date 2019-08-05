//
//  FilterVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 05/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class FilterVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .red
        
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            let frame = self.view.frame
            self.view.frame = CGRect(x: 0, y: 100, width: frame.width, height: frame.height)
        }
    }
}
