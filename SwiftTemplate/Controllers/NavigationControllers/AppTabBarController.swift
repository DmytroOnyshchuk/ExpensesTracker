//
//  AppTabBarController.swift
//  HealthTracker
//
//  Created by Denis Kuznetsov on 27.11.2020.
//  Copyright © 2020 PeaksCircle. All rights reserved.
//

import UIKit

final class AppTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarItems()
        setupTabBarAppearance()
        delegate = self
    }
    
}

private extension AppTabBarController{
    
    private func setupTabBarItems() {
        var viewControllers: [UIViewController] = []
        
        if let mainVC = MainViewController.newInstance?.embeddedInBaseNavigationController {
            mainVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
            viewControllers.append(mainVC)
        }
        if let mainVC2 = MainViewController.newInstance?.embeddedInBaseNavigationController {
            mainVC2.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
            viewControllers.append(mainVC2)
        }
        
        self.viewControllers = viewControllers
        if let index = self.viewControllers?.firstIndex(where: { ($0 as? UINavigationController)?.viewControllers.first is MainViewController }) {
            self.selectedIndex = index
        }
    }
    
    private func setupTabBarAppearance() {
        tabBar.clipsToBounds = false
        tabBar.layer.cornerRadius = 10
        tabBar.layer.masksToBounds = true
        tabBar.layer.shadowRadius = 5
        tabBar.layer.shadowOpacity = 5
        tabBar.layer.shadowOffset = .init(width: 0, height: 5)
        tabBar.isTranslucent = true
        tabBar.barStyle = .black
        tabBar.barTintColor = .white
        tabBar.backgroundColor = .appLightGrey
        tabBar.tintColor = .systemBlue
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        tabBar.itemPositioning = .automatic
    }
    
}

// MARK: - UITabBarControllerDelegate
extension AppTabBarController: UITabBarControllerDelegate {
    
}
