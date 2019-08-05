//
//  ViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class ListVC<T: SongDataSource>: UIViewController, UITableViewDelegate, UITableViewDataSource, UIAdaptivePresentationControllerDelegate {
    
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
    
    var entityName: String!
    var data: [T]!
    var showingData: [T]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        entityName = T.getEntityName()
        
        setViews()
        
        T.registerCell(tableView, forCellReuseIdentifier: "cellId")
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationItem.title = ""
        searchView.searchField.resignFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        searchView.searchField.text = ""
        
        if let index = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: index, animated: false)
        }
    }
    
    // MARK: - View settings
    
    private func setViews() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", metrics: nil, views: ["tableView": tableView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[tableView]|", metrics: nil, views: ["tableView": tableView]))
        
        let filterButton = UIButton()
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.setImage(UIImage(named: "filterIcon"), for: .normal)
        filterButton.tintColor = .black
        filterButton.addTarget(self, action: #selector(showFilters), for: .touchUpInside)
        
        let views = [
            "searchField": searchView.searchField,
            "filterButton": filterButton
        ]
        
        searchView.addSubview(filterButton)
        
        searchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[searchField]-[filterButton(==30)]-|", metrics: nil, views: views))
        searchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[filterButton]-|", metrics: nil, views: views))
    }
    
    func showSearchView(placeholder: String) {
        navigationItem.titleView = searchView
        searchView.searchField.placeholder = placeholder
        searchView.searchField.updateFontSize()
    }
    
    // MARK: - Data Handlers
    
    func loadData() {
        if let data = CoreDataService.fetchData(entityName: entityName, sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)], context: PersistenceService.context) as? [T] {
            self.data = data
            
            updateData(sender: searchView.searchField)
        }
    }
    
    func showData() {
        self.showingData = data
        tableView.reloadData()
    }
    
    func search(predicates: [NSPredicate]) {
        self.showingData = []
        
        for predicate in predicates {
            self.showingData.append(contentsOf: self.data.filter {
                return predicate.evaluate(with: $0)
            })
        }
        
        tableView.reloadData()
    }
    
    @objc func updateData(sender: UITextField) {
        if let searchText = sender.text, searchText.count > 0 {
            search(predicates: T.getPredicates(forSearchText: searchText))
        } else {
            showData()
        }
    }
    
    // MARK: - Handlers
    
    @objc func showFilters() {
        return
        
//        let filterVC = FilterVC()
//
//        let height = view.frame.height - 100
//        let width  = view.frame.width
//        filterVC.view.frame = CGRect(x: 0, y: view.frame.maxY, width: width, height: height)
//
//        addChild(filterVC)
//        view.addSubview(filterVC.view)
//        filterVC.didMove(toParent: self)
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchView.searchField.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showingData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        showingData[indexPath.row].setCell(cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) { }
}
