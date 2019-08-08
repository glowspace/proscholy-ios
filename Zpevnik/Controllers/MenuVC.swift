//
//  MenuViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class MenuVC: UIViewController {
    
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
            aboutVC.descriptionLabel.text = "Vítejte v digitálním zpěvníku ProScholy.cz, který přichází na pomoc všem scholám, křesťanským kapelám, společenstvím a všem, kdo se chtějí modlit hudbou!"
            navigationController?.pushViewController(aboutVC, animated: true)
            break
        case 2:
            let aboutVC = AboutVC()
            aboutVC.setTitle("O Aplikaci")
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
