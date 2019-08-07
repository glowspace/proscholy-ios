//
//  HomeViewController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 24/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class HomeScreenVC: UIViewController {
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let titleImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "homeScreenTitle"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    lazy var searchView: SearchView = {
        let searchView = SearchView()
        searchView.translatesAutoresizingMaskIntoConstraints = false
        
        searchView.layer.cornerRadius = 15
        
        let searchIconView = GradientView()
        searchIconView.translatesAutoresizingMaskIntoConstraints = false
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(red: 0x58, green: 0xC5, blue: 0xCD).cgColor, UIColor(red: 0x5C, green: 0x7F, blue: 0xBF).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        searchIconView.gradientLayer = gradientLayer
        
        searchIconView.layer.cornerRadius = 15
        searchIconView.clipsToBounds = true
        
        let searchIcon = UIImageView(image: UIImage(named: "searchIcon"))
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        
        searchIcon.tintColor = .white
        searchIconView.addSubview(searchIcon)
        
        searchIconView.addConstraint(NSLayoutConstraint(item: searchIcon, attribute: .centerX, relatedBy: .equal, toItem: searchIconView, attribute: .centerX, multiplier: 1, constant: 0))
        searchIconView.addConstraint(NSLayoutConstraint(item: searchIcon, attribute: .centerY, relatedBy: .equal, toItem: searchIconView, attribute: .centerY, multiplier: 1, constant: 0))
        
        let views = [
            "searchField": searchView.searchField,
            "searchIconView": searchIconView
        ]
        
        let metrics = [
            "iconViewWidth": 60,
            "iconViewHeight": 45
        ]
        
        searchView.addSubview(searchIconView)
        
        searchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[searchField]-[searchIconView(iconViewWidth)]|", metrics: metrics, views: views))
        searchView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[searchIconView(iconViewHeight)]|", metrics: metrics, views: views))
        
        searchView.searchField.delegate = self
        searchIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(search)))
        
        return searchView
    }()
    
    lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: createButtons())
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.axis = .vertical
        
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        return stackView
    }()
    
    lazy var allSongLyricsVC: AllSongLyricsListVC = {
        let vc = AllSongLyricsListVC()
        
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        
        setTitle("")
        
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if UserSettings.darkMode {
            backgroundImageView.image = UIImage(named: "darkBackground")
        } else {
            backgroundImageView.image = UIImage(named: "background")
        }
        
        allSongLyricsVC.searchView.searchField.text = ""
        
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
    
    // MARK: - View settings
    
    private func setViews() {
        view.addSubview(backgroundImageView)
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundImageView]|", metrics: nil, views: ["backgroundImageView": backgroundImageView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[backgroundImageView]|", metrics: nil, views: ["backgroundImageView": backgroundImageView]))
        
        view.addSubview(titleImageView)
        view.addSubview(searchView)
        view.addSubview(buttonsStackView)
        
        let views = [
            "titleImageView": titleImageView,
            "searchView": searchView,
            "buttonsStackView": buttonsStackView
        ]
        
        let metrics = [
            "searchViewbottomMargin": 15,
            "buttonsStackHeight": 310
        ]
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[titleImageView]-|", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[searchView]-|", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[buttonsStackView]-|", metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[titleImageView]-[searchView]-(searchViewbottomMargin)-[buttonsStackView(buttonsStackHeight)]", metrics: metrics, views: views))
        view.addConstraint(NSLayoutConstraint(item: titleImageView, attribute: .width, relatedBy: .equal, toItem: titleImageView, attribute: .height, multiplier: 505.0 / 153.0, constant: 0))
        
        searchView.searchField.placeholder = "Zadejte název či číslo písně..."
        searchView.searchField.updateFontSize()
    }
    
    private func createButtons() -> [UIView] {
        let listButton = createGradientButton(icon: UIImage(named: "listIcon"), title: "Zpěvníky", summary: "Vyberte si píseň ze známých zpěvníků", startColor: UIColor(red: 0x87, green: 0x5A, blue: 0xA5), endColor: UIColor(red: 0x62, green: 0x70, blue: 0xB5))
        let favoriteButton = createGradientButton(icon: UIImage(named: "gradeIcon"), title: "Oblíbené", summary: "Vraťte se ke svým oblíbeným písním", startColor: UIColor(red: 0x58, green: 0xC5, blue: 0xCD), endColor: UIColor(red: 0x5C, green: 0x7F, blue: 0xBF))
        let settingsButton = createGradientButton(icon: UIImage(named: "settingsIcon"), title: "Nastavení", summary: "Přizpůsobte si nastavení aplikace", startColor: UIColor(red: 0xF1, green: 0x67, blue: 0x2C), endColor: UIColor(red: 0xF5, green: 0xBA, blue: 0x63))
        
        listButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showLyricsList)))
        favoriteButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showFavorites)))
        settingsButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSettings)))
        
        return [listButton, favoriteButton, settingsButton]
    }
    
    private func createGradientButton(icon: UIImage?, title: String?, summary: String?, startColor: UIColor, endColor: UIColor) -> ButtonView {
        let buttonView = ButtonView()
        buttonView.icon = icon
        buttonView.title = title
        buttonView.summary = summary
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [startColor.cgColor, endColor.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        buttonView.gradientLayer = gradientLayer
        
        return buttonView
    }
    
    // MARK: - Handlers
    
    @objc func showLyricsList() {
        tabBarController?.selectedIndex = 1
        //        navigationController?.pushViewController(allSongLyricsVC, animated: true)
    }
    
    @objc func search() {
        let lyricsListVC = allSongLyricsVC
        lyricsListVC.searchView.searchField.text = searchView.searchField.text
        navigationController?.pushViewController(lyricsListVC, animated: true)
    }
    
    @objc func showFavorites() {
        tabBarController?.selectedIndex = 2
    }
    
    @objc func showSettings() {
        tabBarController?.selectedIndex = 3
        
        if let viewControllers = tabBarController?.viewControllers, let navigationController = viewControllers[3] as? UINavigationController {
            if navigationController.viewControllers.count > 1 {
                navigationController.viewControllers = [navigationController.viewControllers[0]]
            }
            navigationController.viewControllers[0].navigationItem.title = ""
            navigationController.pushViewController(SettingsVC(), animated: false)
        }
    }
    
    @objc override func dismissKeyboard() {
        searchView.searchField.resignFirstResponder()
    }
}

extension HomeScreenVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        search()
        
        return true
    }
}
