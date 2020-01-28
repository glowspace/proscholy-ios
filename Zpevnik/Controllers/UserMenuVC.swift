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
    
    var delegate: UserMenuDelegate?
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
        tableView.isScrollEnabled = false
        
        // disable all panning, so you can hide this view on iPad
        for recognizer in tableView.gestureRecognizers! {
            if recognizer.isEnabled && (recognizer is UIPanGestureRecognizer) {
                recognizer.isEnabled = false
            }
        }
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preferredContentSize = CGSize(width: 200, height: 325)
        
        userNameLabel.text = user?.name ?? "Nepřihlášený uživatel"
        
        setViews()
    }
    
    private func setViews() {
        containerView.addSubview(userNameLabel)
        containerView.addSubview(menuTable)
        
        userNameLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: containerView.leadingAnchor, multiplier: 2).isActive = true
        userNameLabel.topAnchor.constraint(equalToSystemSpacingBelow: containerView.topAnchor, multiplier: 2).isActive = true
        menuTable.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        menuTable.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        menuTable.topAnchor.constraint(equalToSystemSpacingBelow: userNameLabel.bottomAnchor, multiplier: 3).isActive = true
        menuTable.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 0).isActive = true
    }
}

// MARK: - UITableViewDelegate

extension UserMenuVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
            case 0:
                delegate?.presentViewController(SettingsVC(), animated: true)
                dismiss(animated: true)
            case 1:
                openURL("https://zpevnik.proscholy.cz")
            case 2:
                openURL("https://docs.google.com/forms/d/e/1FAIpQLSfI0143gkLBtMbWQnSa9nzpOoBNMokZrOIS5mUreSR41E_B7A/viewform?usp=pp_url&entry.1865829262=ano,+verzi+pro+iOS")
            case 3:
                openURL("https://forms.gle/AYXXxkWtDHQQ13856")
            case 4:
                let aboutVC = AboutVC()
                aboutVC.state = .aboutSongBook
                delegate?.presentViewController(aboutVC, animated: true)
                dismiss(animated: true)
            case 5:
                let aboutVC = AboutVC()
                aboutVC.state = .aboutApp
                delegate?.presentViewController(aboutVC, animated: true)
                dismiss(animated: true)
            default: break
        }
    }
    
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
               
        UIApplication.shared.open(url) { _ in
            self.dismiss(animated: true)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
             shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
       // Do not begin the pan until the swipe fails.
        
//       if gestureRecognizer == self.swipeGesture &&
//              otherGestureRecognizer == self.panGesture {
//          return true
//       }
       return false
    }
}
