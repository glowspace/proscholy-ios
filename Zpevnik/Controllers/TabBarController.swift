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
        case user
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeViewVC = createNavigationController(controller: HomeViewVC(), title: "Domů", image: .home, selectedImage: .homeFilled, tag: 0)
        let songBooksVC = createNavigationController(controller: SongBooksListVC(), title: "Zpěvníky", image: .songBook, selectedImage: .songBook, tag: 1)
        let userViewVC = createNavigationController(controller: UserViewVC(), title: "Já", image: .person, selectedImage: .personFilled, tag: 2)
        
        setViewControllers([homeViewVC, songBooksVC, userViewVC], animated: false)
        
        tabBar.tintColor = .blue
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let menuItemSelected = tabBar.items?.firstIndex(of: item), let tabBarMenuItem = tabBarMenu(rawValue: menuItemSelected) else { return }

        setTintColor(forMenuItem: tabBarMenuItem)
    }
    
    private func createNavigationController(controller: UIViewController, title: String, image: UIImage?, selectedImage: UIImage?, tag: Int) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
        
        let textAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.icon]
        navigationController.navigationBar.titleTextAttributes = textAttributes
        
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
        case .user:
            tabBar.tintColor = .red
            break
        }
    }
}
