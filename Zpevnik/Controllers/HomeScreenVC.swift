//
//  HomeViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class HomeScreenVC: ListVC<SongLyricDataSource> {
    
    override func viewDidLoad() {
        dataSource = SongLyricDataSource()
        
        super.viewDidLoad()
        
        setTitle("")
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchView.searchField.updateFontSize()
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchView.searchField.resignFirstResponder()
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        searchView.searchField.text = ""
    }
    
    // MARK: - Handlers
    
    @objc func search() {
        let lyricsListVC = AllSongLyricsListVC()
        lyricsListVC.searchView.searchField.text = searchView.searchField.text
        navigationController?.pushViewController(lyricsListVC, animated: true)
    }
    
    @objc override func dismissKeyboard() {
        searchView.searchField.resignFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelView = UIView()
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.text = "Abecední seznam všech písní"
        label.textColor = UIColor(named: "logoBlue")
        
        labelView.addSubview(label)
        
        labelView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[label]-|", metrics: nil, views: ["label": label]))
        labelView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[label]-|", metrics: nil, views: ["label": label]))
        
        return labelView
    }
}

extension HomeScreenVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        
        return true
    }
}
