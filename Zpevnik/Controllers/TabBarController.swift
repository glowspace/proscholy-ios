//
//  TabBarController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    enum tabBarMenu: Int {
        case home
        case songBook
        case favorite
        case settings
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if #available(iOS 13, *) {
            return .default
        } else {
            return UserSettings.darkMode ? .lightContent : .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeListVC = createNavigationController(controller: HomeViewVC(), title: "Domů", image: UIImage(named: "homeIcon"), selectedImage: UIImage(named: "homeIconFilled"), tag: 0)
        let songBookListVC = createNavigationController(controller: SongBooksListVC(), title: "Zpěvníky", image: UIImage(named: "songBookIcon"), selectedImage: UIImage(named: "songBookIcon"), tag: 1)
        let favoriteListVC = createNavigationController(controller: FavoriteListVC(), title: "Oblíbené", image: UIImage(named: "starIcon"), selectedImage: UIImage(named: "starIconFilled"), tag: 2)
        let menuVC = createNavigationController(controller: MenuVC(), title: "Ostatní", image: UIImage(named: "menuIcon"), selectedImage: nil, tag: 3)
        
        setViewControllers([homeListVC, songBookListVC, favoriteListVC, menuVC], animated: false)
        
        tabBar.tintColor = .blue
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let menuItemSelected = tabBar.items?.firstIndex(of: item), let tabBarMenuItem = tabBarMenu(rawValue: menuItemSelected) else { return }

        setTintColor(forMenuItem: tabBarMenuItem)
    }
    
    private func createNavigationController(controller: UIViewController, title: String, image: UIImage?, selectedImage: UIImage?, tag: Int) -> NavigationController {
        let navigationController = NavigationController(rootViewController: controller)
        navigationController.tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
        
        navigationController.tabBarItem.selectedImage = selectedImage
        navigationController.view.backgroundColor = .white
        
        return navigationController
    }
    
    private func setTintColor(forMenuItem tabBarMenuItem: tabBarMenu) {
        switch(tabBarMenuItem) {
        case .home:
            tabBar.tintColor = .blue
            break
        case .songBook:
            tabBar.tintColor = .green
            break
        case .favorite:
            break
        case .settings:
            break
        }
    }
}
