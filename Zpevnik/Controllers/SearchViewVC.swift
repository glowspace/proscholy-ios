//
//  MainVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 03/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SearchViewVC: VC {
    
    internal var isSearching = false
    
    internal lazy var searchView: SearchView = {
        let searchView = SearchView(leadingButton: UIButton(type: .custom), trailingButton: UIButton(type: .custom))
        
        searchView.searchField.delegate = self
        
        searchView.leadingButton?.setImage(.search, for: .normal)
        searchView.trailingButton?.setImage(.filter, for: .normal)
        
        searchView.leadingButton?.addTarget(self, action: #selector(toggleSearch), for: .touchUpInside)
        
        return searchView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        addSearchView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchView.searchField.resignFirstResponder()
    }
    
    internal func addSearchView() {
        view.addSubview(searchView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-8-[searchView]-8-|", metrics: nil, views: ["searchView": searchView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[searchView(==36)]", metrics: nil, views: ["searchView": searchView]))
    }
    
    internal func setPlaceholder(_ placeholder: String) {
        searchView.searchField.placeholder = placeholder
        searchView.searchField.updateFontSize()
    }
}

extension SearchViewVC: UITextFieldDelegate {
    
    @objc func toggleSearch() {
        if isSearching {
            isSearching = false
            
            searchView.searchField.resignFirstResponder()
            searchView.searchField.text = ""
            searchView.leadingButton?.setImage(.search, for: .normal)
        } else {
            searchView.searchField.becomeFirstResponder()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        searchView.leadingButton?.setImage(.back, for: .normal)
        isSearching = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        searchView.searchField.resignFirstResponder()
    }
}
