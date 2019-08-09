//
//  MenuViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class MenuVC: ViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.isScrollEnabled = false
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(TableViewCell.self, forCellReuseIdentifier: "cellId")
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", metrics: nil, views: ["tableView": tableView]))
        
        setTitle("Zpěvník pro scholy", iconImage: UIImage(named: "logo"))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }
}

extension MenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        cell.textLabel?.text = ["Nastavení", "O zpěvníku", "O aplikaci", "Webová verze", "Zpětná vazba"][indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(SettingsVC(), animated: true)
            break
        case 1:
            let aboutVC = AboutVC()
            aboutVC.setTitle("O Zpěvníku")
            
            let description = """
            Zpěvník ProScholy.cz, který přichází na pomoc všem scholám, křesťanským kapelám, společenstvím a všem, kdo se chtějí modlit hudbou!

            Projekt vzniká se svolením České biskupské konference.

            Další informace o stavu a rozvoji projektu naleznete na https://zpevnik.proscholy.cz
            """
            
            let attributedDescription = NSMutableAttributedString(string: description, attributes: [.font: UIFont.getFont(ofSize: 15)])
            
            if let range = description.range(of: "České biskupské konference") {
                attributedDescription.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 18), range: NSRange(range, in: description))
            }
            
            aboutVC.descriptionTextView.attributedText = attributedDescription
            
            navigationController?.pushViewController(aboutVC, animated: true)
            break
        case 2:
            let aboutVC = AboutVC()
            aboutVC.setTitle("O Aplikaci")
            
            let description = """
            Zpěvník pro scholy verze 1.2
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
            
            aboutVC.descriptionTextView.attributedText = attributedDescription
            
            navigationController?.pushViewController(aboutVC, animated: true)
            break
        case 3:
            guard let url = URL(string: "https://zpevnik.proscholy.cz") else { return }
            UIApplication.shared.open(url)
            break
        case 4:
            guard let url = URL(string: "https://forms.gle/cQHPxkEwWbzMVNYd7") else { return }
            UIApplication.shared.open(url)
            break
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
