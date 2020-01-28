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
    
    private lazy var playlistsList: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = playlistDataSource
        tableView.delegate = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "playlistCell")
        
        tableView.separatorStyle = .none
        
        tableView.setEditing(true, animated: false)
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress)))
        
        return tableView
    }()
    
    private lazy var userCell: UserCell = {
        let userCell = UserCell()
        userCell.translatesAutoresizingMaskIntoConstraints = false
        
        userCell.delegate = self
        
        return userCell
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userCell.userName = user?.name ?? "Nepřihlášený uživatel"
        
        setViews()
    }
    
    private func setViews() {
        view.addSubview(playlistsList)
        view.addSubview(userCell)
        
        playlistsList.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        playlistsList.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playlistsList.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        userCell.topAnchor.constraint(equalToSystemSpacingBelow: playlistsList.bottomAnchor, multiplier: 1).isActive = true
        userCell.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        userCell.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        userCell.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        userCell.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    fileprivate var sourceIndexPath: IndexPath?
    fileprivate var snapshot: UIView?
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

// MARK: - UserMenuDelegate

extension UserViewVC: UserMenuDelegate {
    
    func presentViewController(_ viewController: UIViewController, animated: Bool) {
        navigationController?.pushViewController(viewController, animated: animated)
    }
}

// MARK: - MoveCellHandler, UITableViewDelegate

extension UserViewVC: UITableViewDelegate {
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }
//
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    
    @objc func longPress(_ longPress: UILongPressGestureRecognizer) {
        let state = longPress.state
        let location = longPress.location(in: playlistsList)
        guard let indexPath = playlistsList.indexPathForRow(at: location) else { return }
        switch state {
          case .began:
          sourceIndexPath = indexPath
          guard let cell = playlistsList.cellForRow(at: indexPath) else { return }
          // Take a snapshot of the selected row using helper method. See below method
          snapshot = self.customSnapshotFromView(inputView: cell)
          guard let snapshot = self.snapshot else { return }
          var center = cell.center
          snapshot.center = center
          snapshot.alpha = 0.0
          playlistsList.addSubview(snapshot)
          UIView.animate(withDuration: 0.3, animations: {
            center.y = location.y
            snapshot.center = center
            snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            snapshot.alpha = 0.98
            cell.alpha = 0.0
          }, completion: { (finished) in
            cell.isHidden = true
          })
            case .changed:
            guard  let snapshot = self.snapshot else {
              return
            }
            var center = snapshot.center
            center.y = location.y
            snapshot.center = center
            guard let sourceIndexPath = self.sourceIndexPath  else {
              return
            }
            if indexPath != sourceIndexPath {
//              swap(&data[indexPath.row], &data[sourceIndexPath.row])
              playlistsList.moveRow(at: sourceIndexPath, to: indexPath)
              self.sourceIndexPath = indexPath
            }
          default:
          guard let cell = playlistsList.cellForRow(at: indexPath) else {
              return
            }
            guard  let snapshot = self.snapshot else {
              return
            }
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.3, animations: {
              snapshot.center = cell.center
              snapshot.transform = CGAffineTransform.identity
              snapshot.alpha = 0
              cell.alpha = 1
            }, completion: { (finished) in
             self.sourceIndexPath = nil
            snapshot.removeFromSuperview()
             self.snapshot = nil
          })
        }
    }
    
    private func customSnapshotFromView(inputView: UIView) -> UIView? {
      UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0)
      if let CurrentContext = UIGraphicsGetCurrentContext() {
        inputView.layer.render(in: CurrentContext)
      }
      guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
        UIGraphicsEndImageContext()
        return nil
      }
      UIGraphicsEndImageContext()
      let snapshot = UIImageView(image: image)
      snapshot.layer.masksToBounds = false
      snapshot.layer.cornerRadius = 0
      snapshot.layer.shadowOffset = CGSize(width: -5, height: 0)
      snapshot.layer.shadowRadius = 5
      snapshot.layer.shadowOpacity = 0.4
      return snapshot
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
