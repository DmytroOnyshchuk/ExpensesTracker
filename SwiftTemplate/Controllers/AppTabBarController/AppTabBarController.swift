//
//  AppTabBarController.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
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

private extension AppTabBarController {
    
    private func setupTabBarItems() {
        var viewControllers: [UIViewController] = []
        
        if let mainViewController = CountriesViewController.newInstance?.embeddedInBaseNavigationController {
            mainViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
            viewControllers.append(mainViewController)
        }
        if let usersViewController = UsersViewController.newInstance?.embeddedInBaseNavigationController {
            usersViewController.tabBarItem = UITabBarItem(title: nil, image: UIImage(systemName: "person"), selectedImage: UIImage(systemName: "person.fill"))
            viewControllers.append(usersViewController)
        }
        
        self.viewControllers = viewControllers
        if let index = self.viewControllers?.firstIndex(where: { ($0 as? UINavigationController)?.viewControllers.first is CountriesViewController }) {
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
   
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        switch viewController.topMostViewController {
            case is CountriesViewController:
                NotificationCenter.default.post(name: .mainScrollToTop, object: nil)
            case is UsersViewController:
                NotificationCenter.default.post(name: .usersScrollToTop, object: nil)
            default:
                break
        }
    }
    
}
