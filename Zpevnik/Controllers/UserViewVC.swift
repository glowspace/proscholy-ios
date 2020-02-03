//
//  UserViewVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 03/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class UserViewVC: SearchViewVC {
    
    private let playlistDataSource: PlaylistDataSource = { PlaylistDataSource(user!) }()
    private let optionsDataSource = OptionsDataSource()
    
    private lazy var playlistsList: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = playlistDataSource
        tableView.delegate = self
        
        tableView.register(MoreOptionsCell.self, forCellReuseIdentifier: "playlistCell")
        
        tableView.separatorStyle = .none
        
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
        
        return tableView
    }()
    
    private lazy var userCell: UserCell = {
        let userCell = UserCell()
        userCell.translatesAutoresizingMaskIntoConstraints = false
        
        userCell.delegate = self
        
        return userCell
    }()
    
    private lazy var optionsTable: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = optionsDataSource
        tableView.delegate = self
        
        tableView.isHidden = true
        
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        
        tableView.register(MoreOptionsCell.self, forCellReuseIdentifier: "moreOptionsCell")
        
        tableView.layer.borderColor = UIColor.gray4.cgColor
        tableView.layer.borderWidth = 1
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userCell.userName = user?.name ?? "Nepřihlášený uživatel"
        
        setViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setViews() {
        addSearchView()
        setPlaceholder("Zadejte slovo nebo číslo")
        
        view.addSubview(playlistsList)
        view.addSubview(userCell)
        
        playlistsList.topAnchor.constraint(equalTo: searchView.bottomAnchor).isActive = true
        playlistsList.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playlistsList.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        userCell.topAnchor.constraint(equalToSystemSpacingBelow: playlistsList.bottomAnchor, multiplier: 1).isActive = true
        userCell.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        userCell.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        userCell.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        userCell.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    private func addSearchView() {
        view.addSubview(searchView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[searchView]-8-|", metrics: nil, views: ["searchView": searchView]))
        
        searchView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIApplication.shared.statusBarFrame.height).isActive = true
        searchView.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    private var sourceIndexPath: IndexPath?
    private var snapshot: UIImageView?
}

// MARK: - UserCellDelegate

extension UserViewVC: UserCellDelegate {
    
    func showUserMenu() {
        halfViewPresentationManager.heightMultiplier = 325 / view.frame.height
        
        let userMenuVc = UserMenuVC()
        userMenuVc.delegate = self
        userMenuVc.user = user
        
        presentModally(userMenuVc, animated: true)
    }
}

// MARK: - UITableViewDelegate

extension UserViewVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        playlistDataSource.currentIndexPath = playlistDataSource.currentIndexPath ?? sourceIndexPath
        
        if !(tableView.dataSource?.tableView?(tableView, canMoveRowAt: proposedDestinationIndexPath) ?? false) {
            return playlistDataSource.currentIndexPath!
        }
        
        playlistDataSource.currentIndexPath = proposedDestinationIndexPath
        
        return proposedDestinationIndexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let songListViewVC = ReorderableSongListViewVC()
        
        if(indexPath.row == 0) {
            songListViewVC.dataSource = FavoriteSongLyricDataSource()
        } else {
            songListViewVC.dataSource = PlaylistSongLyricDataSource(playlistDataSource.playlists[indexPath.row - 1])
        }
        
        navigationController?.pushViewController(songListViewVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return tableView.sectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return TableViewHeader("Seznamy písní", .red)
    }
}

// MARK: - UserMenuDelegate

extension UserViewVC: UserMenuDelegate {
    
    func presentViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
}

//import Firebase
//import GoogleSignIn

//class UserViewVC: SearchViewVC {
//
//    let googleSignInButton: GIDSignInButton = {
//        let button = GIDSignInButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//
//        button.style = .iconOnly
//
//        return button
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        GIDSignIn.sharedInstance()?.presentingViewController = self
//
//        let currentUser = Auth.auth().currentUser
//        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
//            if let error = error {
//                print(error)
//                return;
//            }
//
//            print(idToken)
//        }
//
//        view.addSubview(googleSignInButton)
//
//        googleSignInButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        googleSignInButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//    }
//}
