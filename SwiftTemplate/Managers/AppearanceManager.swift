//
//  AppearanceManager.swift
//  HealthTracker
//
//  Created by Denis Kuznetsov on 27.11.2020.
//  Copyright © 2020 PeaksCircle. All rights reserved.
//

import UIKit

final class AppearanceManager {
    
    static var appNavigationController: AppNavigationController?
    
    static var appTabBarController: AppTabBarController? {
        return appNavigationController?.rootViewController as? AppTabBarController
    }
    
    @discardableResult
    static func showAppTabBarController<T: UIViewController>(vc: T.Type) -> T? {
        guard let tabBarController = appTabBarController else { return nil }
        
        for (index, viewController) in (tabBarController.viewControllers ?? []).enumerated() {
            if let navigationController = viewController as? UINavigationController {
                for child in navigationController.viewControllers {
                    if let typedVC = child as? T {
                        tabBarController.selectedIndex = index
                        return typedVC
                    }
                }
            } else if let typedVC = viewController as? T {
                tabBarController.selectedIndex = index
                return typedVC
            }
        }
        
        return nil
    }
    
    @discardableResult
    static func getAppTabBarController<T: UIViewController>(vc: T.Type) -> T? {
        guard let tabBarController = appTabBarController else { return nil }
        
        for (index, viewController) in (tabBarController.viewControllers ?? []).enumerated() {
            if let navigationController = viewController as? UINavigationController {
                for child in navigationController.viewControllers {
                    if let typedVC = child as? T {
                        return typedVC
                    }
                }
            } else if let typedVC = viewController as? T {
                return typedVC
            }
        }
        
        return nil
    }
    
    static func showAppTabBarController(tab: Int) {
        appTabBarController?.selectedIndex = tab
    }
    
    static func isActiveViewController<T: UIViewController>(ofType type: T.Type) -> Bool {
        guard let tabBarController = appTabBarController else { return false }
        
        if let selectedController = tabBarController.selectedViewController {
            if let navigationController = selectedController as? UINavigationController {
                return navigationController.viewControllers.contains { $0 is T }
            } else {
                return selectedController is T
            }
        }
        
        return false
    }
    
}
