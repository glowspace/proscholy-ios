//
//  MainVC.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 03/01/2020.
//  Copyright © 2020 Patrik Dobiáš. All rights reserved.
//

import UIKit

class SearchViewVC: ViewController {
    
    internal var isSearching = false
    
    internal lazy var searchView: SearchView = {
        let searchView = SearchView(leadingButton: UIButton(type: .custom), trailingButton: UIButton(type: .custom))
        
        searchView.searchField.delegate = self
        
        searchView.leadingButton?.setImage(.search, for: .normal)
        searchView.trailingButton?.setImage(.filter, for: .normal)
        
        searchView.leadingButton?.addTarget(self, action: #selector(toggleSearch), for: .touchUpInside)
        searchView.searchField.addTarget(self, action: #selector(searchTextChanged(sender:)), for: .editingChanged)
        
        return searchView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        searchView.searchField.resignFirstResponder()
    }
    
    internal func setPlaceholder(_ placeholder: String) {
        searchView.searchField.placeholder = placeholder
        searchView.searchField.updateFontSize()
    }
}

// MARK: UITextFieldDelegate

extension SearchViewVC: UITextFieldDelegate {
    
    @objc func toggleSearch() {
        if isSearching {
            isSearching = false
            
            searchView.searchField.resignFirstResponder()
            searchView.searchField.text = ""
            searchView.searchField.clearButtonMode = .never
        } else {
            searchView.searchField.becomeFirstResponder()
        }
    }
    
    @objc func searchTextChanged(sender: UITextField) {
        searchView.searchField.clearButtonMode = (sender.text?.count ?? 0) > 0 ? .always : .never
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
