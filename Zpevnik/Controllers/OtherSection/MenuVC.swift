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

        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if #available(iOS 13, *) {
            navigationController?.navigationBar.barTintColor = Constants.getMiddleColor(traitCollection.userInterfaceStyle)
        }
    }
}

extension MenuVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        if #available(iOS 13, *) {
            cell.selectedBackgroundView?.backgroundColor = Constants.getMiddleColor(traitCollection.userInterfaceStyle) ?? UIColor(white: 0.85, alpha: 1)
        }
        
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
            aboutVC.state = .aboutSongBook
                       
            navigationController?.pushViewController(aboutVC, animated: true)
            break
        case 2:
            let aboutVC = AboutVC()
            aboutVC.state = .aboutApp
            
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
