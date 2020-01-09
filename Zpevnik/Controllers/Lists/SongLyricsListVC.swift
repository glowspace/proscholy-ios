//
//  SongLyricsListVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 02/08/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SongLyricsListVC {
//class SongLyricsListVC: ListVC<SongBookDataSource> { // ListVC<SongLyricDataSource_> {
    
//    var currentSongLyricIndex: Int?
//
//    lazy var songLyricVC: SongLyricVC = {
//        let vc = SongLyricVC()
//
//        vc.delegate = self
//
//        return vc
//    }()
//
//    lazy var filterButton: UIButton = {
//        let button = UIButton()
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setImage(UIImage(named: "filterIcon"), for: .normal)
//        button.addTarget(self, action: #selector(toggleFilters), for: .touchUpInside)
//        return button
//    }()
//
//    lazy var panGesture: UIPanGestureRecognizer = {
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
//        panGesture.maximumNumberOfTouches = 1
//
//        return panGesture
//    }()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        if #available(iOS 13, *) {
//            navigationController?.navigationBar.barTintColor = Constants.getMiddleColor(traitCollection.userInterfaceStyle)
//            filterButton.tintColor = Constants.getLightColor(traitCollection.userInterfaceStyle) ?? .black
//        } else {
//            filterButton.tintColor = Constants.getLightColor() ?? .black
//        }
//    }
//
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//
//        if isMovingFromParent && showingFilter {
//            toggleFilters()
//        }
//    }
//
//    // MARK: - Filter VC
//
//    lazy var filterVC: FilterVC = {
//        let vc = FilterVC()
//        vc.delegate = self
//
//        return vc
//    }()
//
//    var showingFilter = false
//
//    var filterShadow: UIView?
//
//    @objc func toggleFilters() {
//        searchView.searchField.resignFirstResponder()
//
//        if !showingFilter {
//            let height = view.frame.height
//            let width  = view.frame.width
//            filterVC.view.frame = CGRect(x: 0, y: view.frame.minY - height, width: width, height: height)
//
//            addChild(filterVC)
//            filterShadow = UIView(frame: tableView.frame)
//            filterShadow?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleFilters)))
//            view.addSubview(filterShadow!)
//            view.addSubview(filterVC.view)
//
//            tableView.isUserInteractionEnabled = false
//            UIView.animate(withDuration: 0.3) {
//                self.filterVC.view.frame.origin.y = -height * 0.25
//                self.filterShadow?.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//            }
//
//            view.addGestureRecognizer(panGesture)
//        } else {
//            filterVC.removeFromParent()
//            UIView.animate(withDuration: 0.3, animations:  {
//                self.filterVC.view.frame.origin.y = -self.view.frame.height
//                self.filterShadow?.backgroundColor = UIColor.black.withAlphaComponent(0)
//            }) { _ in
//                self.filterVC.view.removeFromSuperview()
//                self.filterShadow?.removeFromSuperview()
//                self.tableView.isUserInteractionEnabled = true
//            }
//
//            view.removeGestureRecognizer(panGesture)
//        }
//        showingFilter = !showingFilter
//    }
//
//    @objc func didPan(sender: UIPanGestureRecognizer) {
//        let y = sender.location(in: view).y
//        if filterVC.view.frame.origin.y + filterVC.view.frame.height - y > 50 {
//            return
//        }
//
//        filterVC.view.frame.origin.y = y - filterVC.view.frame.height
//
//        if filterVC.view.frame.origin.y > -filterVC.view.frame.height * 0.25 {
//            filterVC.tagsViewTopConstraint.constant = -filterVC.view.frame.origin.y
//        }
//
//        if sender.state == .ended {
//            if abs(filterVC.view.frame.origin.y) > filterVC.view.frame.height * 0.25 {
//                let duration = 0.3
//                filterVC.removeFromParent()
//                UIView.animate(withDuration: duration, animations:  {
//                    self.filterVC.view.frame.origin.y = -self.view.frame.height
//                    if let filterShadow = self.filterShadow {
//                        filterShadow.backgroundColor = UIColor.black.withAlphaComponent(0)
//                    }
//                }) { _ in
//                    self.filterVC.view.removeFromSuperview()
//                    if let filterShadow = self.filterShadow {
//                        filterShadow.removeFromSuperview()
//                    }
//                    self.tableView.isUserInteractionEnabled = true
//                }
//                showingFilter = false
//            } else {
//                let duration = 0.3
//                self.filterVC.tagsViewTopConstraint.constant = filterVC.view.frame.height * 0.25
//                UIView.animate(withDuration: duration, animations: {
//                    self.filterVC.view.frame.origin.y = -self.filterVC.view.frame.height * 0.25
//                    self.filterVC.view.layoutIfNeeded()
//                })
//            }
//        }
//    }
//
//    override internal func setViews() {
//        super.setViews()
//
//        let views = [
//            "searchField": searchView.searchField,
//            "filterButton": filterButton
//        ]
//
//        searchView.addSubview(filterButton)
//
//        searchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[searchField]-[filterButton(==30)]-|", metrics: nil, views: views))
//        searchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[filterButton]-|", metrics: nil, views: views))
//    }
//
//    // MARK: - UITableViewDelegate, UITableViewDataSource
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        currentSongLyricIndex = indexPath.row
//
//        songLyricVC.songLyric = dataSource.showingData[indexPath.row]
//        navigationController?.pushViewController(songLyricVC, animated: true)
//    }
}

//extension SongLyricsListVC: FilterDelegate {
//    
//    func updateSelected() {
//        dataSource.activeFilters = filterVC.usingFilter
//        dataSource.selectedTags = filterVC.selectedTags
//        
//        tableView.reloadData()
//    }
//}
//
//extension SongLyricsListVC: SongLyricDelegate {
//    
//    func changeSongLyric(_ controller: SongLyricVC, change: Int) {
//        if var currentSongLyricIndex = currentSongLyricIndex {
//            currentSongLyricIndex = (currentSongLyricIndex + change) % dataSource.showingData.count
//            if currentSongLyricIndex < 0 {
//                currentSongLyricIndex = dataSource.showingData.count - 1
//            }
//            controller.songLyric = dataSource.showingData[currentSongLyricIndex]
//            controller.updateSongLyrics()
//            controller.scrollView.showsVerticalScrollIndicator = false
//            controller.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
//            controller.scrollView.showsVerticalScrollIndicator = true
//            self.currentSongLyricIndex = currentSongLyricIndex
//        }
//    }
//}
