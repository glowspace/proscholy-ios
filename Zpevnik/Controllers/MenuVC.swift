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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", metrics: nil, views: ["tableView": tableView]))
        
        navigationItem.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let view = UIView()
        
        let logoView = UIImageView(image: UIImage(named: "logo"))
        logoView.translatesAutoresizingMaskIntoConstraints = false
        
        let titleView = UILabel()
        titleView.translatesAutoresizingMaskIntoConstraints = false
        
        titleView.text = "Zpěvník pro scholy"
        titleView.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.semibold)
        
        view.addSubview(logoView)
        view.addSubview(titleView)
        
        let views = [
            "logoView": logoView,
            "titleView": titleView
        ]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[logoView(==40)]-[titleView]-|", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[logoView(==40)]|", options: [.alignAllCenterY], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[titleView]|", options: [.alignAllCenterY], metrics: nil, views: views))
        
        navigationItem.titleView = view
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
        case 3:
            guard let url = URL(string: "https://zpevnik.proscholy.cz") else { return }
            UIApplication.shared.open(url)
            break
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
