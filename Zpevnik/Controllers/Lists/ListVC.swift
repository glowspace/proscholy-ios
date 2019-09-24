//
//  ViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit
import CoreData

class ListVC<T: DataSource>: ViewController, UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate {
    
    lazy var searchView: SearchView = {
        let searchView = SearchView()
        
        searchView.searchField.addTarget(self, action: #selector(updateData(sender:)), for: .editingChanged)
        
        return searchView
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    var dataSource: T!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        
        dataSource.registerCell(tableView, forCellReuseIdentifier: "cellId")
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        searchView.searchField.updateFontSize()
        
        dataSource.searchText = searchView.searchField.text
        
        dataSource.updateData()
        
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setTitle("")
        searchView.searchField.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: false)
        }
    }
    
    // MARK: - View Settings
    
    internal func setViews() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[tableView]|", metrics: nil, views: ["tableView": tableView]))
    }
    
    func showSearchView(placeholder: String) {
        navigationItem.titleView = searchView
        searchView.searchField.placeholder = placeholder
        searchView.searchField.updateFontSize()
    }
    
    // MARK: - Data Handlers
    
    @objc func updateData(sender: UITextField) {
        dataSource.searchText = sender.text
        
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchView.searchField.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.showingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        if #available(iOS 13, *) {
            cell.selectedBackgroundView?.backgroundColor = Constants.getMiddleColor(traitCollection.userInterfaceStyle) ?? UIColor(white: 0.85, alpha: 1)
        }
        
        dataSource.setCell(cell, dataSource.showingData[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        return proposedDestinationIndexPath
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}
