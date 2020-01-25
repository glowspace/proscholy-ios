//
//  UserMenuVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 25/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class UserMenuVC: HalfViewController {
    
    private let optionsDataSource = OptionsDataSource(.settings)
    
    var delegate: UserViewVC?
    var user: User?
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var menuTable: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = optionsDataSource
        tableView.delegate = self
        
        tableView.register(MoreOptionsCell.self, forCellReuseIdentifier: "moreOptionsCell")
        
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameLabel.text = user?.name ?? "Nepřihlášený uživatel"
        
        setViews()
    }
    
    private func setViews() {
        view.addSubview(userNameLabel)
        view.addSubview(menuTable)
        
        userNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2).isActive = true
        userNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.topAnchor, multiplier: 2).isActive = true
        menuTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        menuTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8).isActive = true
        menuTable.topAnchor.constraint(equalToSystemSpacingBelow: userNameLabel.bottomAnchor, multiplier: 3).isActive = true
        menuTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
}

// MARK: - UITableViewDelegate

extension UserMenuVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
            case 0:
                delegate?.navigationController?.pushViewController(SettingsVC(), animated: true)
                self.dismiss(animated: true)
            case 1:
                openURL("https://zpevnik.proscholy.cz")
            case 2:
                openURL("https://docs.google.com/forms/d/e/1FAIpQLSfI0143gkLBtMbWQnSa9nzpOoBNMokZrOIS5mUreSR41E_B7A/viewform?usp=pp_url&entry.1865829262=ano,+verzi+pro+iOS")
            case 3:
                openURL("https://forms.gle/AYXXxkWtDHQQ13856")
            case 4:
                let aboutVC = AboutVC()
                aboutVC.state = .aboutSongBook
                delegate?.navigationController?.pushViewController(aboutVC, animated: true)
                self.dismiss(animated: true)
            case 5:
                let aboutVC = AboutVC()
                aboutVC.state = .aboutApp
                delegate?.navigationController?.pushViewController(aboutVC, animated: true)
                self.dismiss(animated: true)
            default: break
        }
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
               
        UIApplication.shared.open(url) { _ in
            self.dismiss(animated: true)
        }
    }
}
