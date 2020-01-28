//
//  HalfViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class HalfViewController: ViewController {
    
    private let cornerRadius: CGFloat = 10
    
    var screenshotVC: ScreenshotVC?
    
    private let handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.backgroundColor = .gray2
        
        view.layer.cornerRadius = 3
        
        return view
    }()
    
    internal lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        view.clipsToBounds = true
        view.layer.cornerRadius = cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .clear
        
        setViews()
    }
    
    private func setViews() {
        view.addSubview(handleView)
        view.addSubview(containerView)
        
        handleView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        handleView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        handleView.heightAnchor.constraint(equalToConstant: 6).isActive = true
        
        containerView.topAnchor.constraint(equalToSystemSpacingBelow: handleView.bottomAnchor, multiplier: 1).isActive = true
        
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
