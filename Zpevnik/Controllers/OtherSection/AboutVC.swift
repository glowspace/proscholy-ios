//
//  AboutVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 08/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

enum AboutState {
    case aboutSongBook, aboutApp
}

class AboutVC: ViewController {
    
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 5, right: 5)
        
        textView.delegate = self
        
        textView.isEditable = false
        textView.dataDetectorTypes = [.link]
        
        textView.textContainer.lineBreakMode = .byWordWrapping
        
        return textView
    }()
    
    var state: AboutState? {
        didSet {
            setDescription()
        }
    }
    
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
    
    private func setDescription() {
        guard let state = state else { return }
        
        switch state {
        case .aboutSongBook:
            setTitle("O Zpěvníku")
            
            let description = """
                Zpěvník ProScholy.cz, který přichází na pomoc všem scholám, křesťanským kapelám, společenstvím a všem, kdo se chtějí modlit hudbou!

                Projekt vzniká se svolením České biskupské konference.

                Další informace o stavu a rozvoji projektu naleznete na https://zpevnik.proscholy.cz
                """
            
            let attributedDescription = NSMutableAttributedString(string: description, attributes: [.font: UIFont.getFont(ofSize: 15)])
            
            if let range = description.range(of: "České biskupské konference") {
                attributedDescription.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 18), range: NSRange(range, in: description))
            }
            
            descriptionTextView.attributedText = attributedDescription
            break
        case .aboutApp:
            setTitle("O Aplikaci")
            
            var description = ""
            if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                description += String(format: "Zpěvník pro scholy verze %@\n", currentVersion)
            }
            
            description += """
            Offline mobilní verze pro iOS.

            Autor mobilní aplikace: Patrik Dobiáš
            
            Na vývoji se stále pracuje.
            
            Případné chyby, připomínky, nápady či postřehy k této aplikaci, prosím, uveďte na adresu patrikdobidobias@icloud.com
            """
            
            let attributedDescription = NSMutableAttributedString(string: description, attributes: [.font: UIFont.getFont(ofSize: 15)])
            
            for version in ["1.0", "1.1", "1.2"] {
                if let range = description.range(of: "Verze " + version) {
                    attributedDescription.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 18), range: NSRange(range, in: description))
                }
            }
            
            descriptionTextView.attributedText = attributedDescription
            break
        }
    }
}

extension AboutVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
