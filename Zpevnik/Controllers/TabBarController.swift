//
//  TabBarController.swift
//  Zpevnik
//
//  Created by Patrik Dobiáš on 23/07/2019.
//  Copyright © 2019 Patrik Dobiáš. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeListVC = createNavigationController(controller: HomeScreenVC(), title: "Domů", image: UIImage(named: "homeIcon"), selectedImage: UIImage(named: "homeIconFilled"), tag: 0)
        let songBookListVC = createNavigationController(controller: SongBooksListVC(), title: "Zpěvníky", image: UIImage(named: "songBookIcon"), selectedImage: UIImage(named: "songBookIconFilled"), tag: 1)
        let favoriteListVC = createNavigationController(controller: FavoriteListVC(), title: "Oblíbené", image: UIImage(named: "starIcon"), selectedImage: UIImage(named: "starIconFilled"), tag: 2)
        let menuVC = createNavigationController(controller: MenuVC(), title: "Ostatní", image: UIImage(named: "menuIcon"), selectedImage: nil, tag: 3)
        
        setViewControllers([homeListVC, songBookListVC, favoriteListVC, menuVC], animated: false)
    }
    
    private func createNavigationController(controller: UIViewController, title: String, image: UIImage?, selectedImage: UIImage?, tag: Int) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.tabBarItem = UITabBarItem(title: title, image: image, tag: tag)
        
        navigationController.tabBarItem.selectedImage = selectedImage
        navigationController.view.backgroundColor = .white
        
        return navigationController
    }
}
