//
//  AboutVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 08/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class AboutVC: ViewController {
    
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
        
        textView.delegate = self
        
        textView.isEditable = false
        textView.dataDetectorTypes = [.link, .address]
        
        textView.textContainer.lineBreakMode = .byWordWrapping
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(descriptionTextView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[descriptionTextView]|", metrics: nil, views: ["descriptionTextView": descriptionTextView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[descriptionTextView]-|", metrics: nil, views: ["descriptionTextView": descriptionTextView]))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = Constants.getDarkColor() ?? .groupTableViewBackground
    }
}

extension AboutVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
