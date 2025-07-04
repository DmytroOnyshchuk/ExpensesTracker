//
//  Coordinator.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import UIKit

protocol Coordinator {
    
    var appNavigationController: AppNavigationController { get set }
    var appTabBarController: AppTabBarController? { get }
    // AppTabBarController
    @discardableResult
    func showAppTabBarController<T: UIViewController>(vc: T.Type) -> T?
    @discardableResult
    func getAppTabBarController<T: UIViewController>(vc: T.Type) -> T?
    func showAppTabBarController(tab: Int)
    func isActiveViewController<T: UIViewController>(ofType type: T.Type) -> Bool
    
    func pushViewControllerSafe(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void)
    func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void)
    
    @MainActor func start()
    @MainActor func showCountries()
    @MainActor func showLogin()
}

final class AppCoordinator: Coordinator {
    
    @Inject private var userManager: UserManager
    
    var appNavigationController: AppNavigationController
    
    var appTabBarController: AppTabBarController? {
        return appNavigationController.rootViewController as? AppTabBarController
    }
    
    init(appNavigationController: AppNavigationController) {
        self.appNavigationController = appNavigationController
    }
    
    @MainActor
    func start() {
        if userManager.isLoggedIn(){
            let appTabBarController = AppTabBarController()
            appNavigationController = appTabBarController.embeddedInAppNavigationController
            UIApplication.load(vc: appNavigationController)
        }else{
            if let startViewController = StartViewController.newInstance {
                appNavigationController = startViewController.embeddedInAppNavigationController
                UIApplication.load(vc: appNavigationController)
            }
        }
    }
    
    @MainActor
    func showCountries() {
        userManager.userId = Int.random.asString
        NotificationCenter.default.post(name: .appLogin, object: nil)
        start()
    }
    
    @MainActor
    func showLogin() {
        if let loginViewController = LoginViewController.newInstance {
            appNavigationController = loginViewController.embeddedInAppNavigationController
            UIApplication.load(vc: appNavigationController)
        }
    }
    
}

extension Coordinator {
    
    func popToViewController(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void) {
        DispatchQueue.main.async { [self] in
            appNavigationController.popToViewController(viewController, animated: animated)
            guard animated, let coordinator = appNavigationController.transitionCoordinator else {
                DispatchQueue.main.async { completion() }
                return
            }
            coordinator.animate(alongsideTransition: nil) { _ in completion() }
        }
    }
    
    // thread safe & completion-able implementation of pushViewController(:animated:)
    func pushViewControllerSafe(_ viewController: UIViewController, animated: Bool, completion: @escaping () -> Void = {}) {
        if appNavigationController.viewControllers.contains(viewController) {
            //app will crash if ut pushes the same view controller twice
            completion()
            return
        }
        DispatchQueue.main.async { [self] in
            appNavigationController.pushViewController(viewController, animated: animated)
            guard animated, let coordinator = appNavigationController.transitionCoordinator else {
                completion()
                return
            }
            coordinator.animate(alongsideTransition: nil) { [completion] _ in
                completion()
            }
        }
    }
    
}

extension Coordinator {
    
    @discardableResult
    func showAppTabBarController<T: UIViewController>(vc: T.Type) -> T? {
        guard let tabBarController = appTabBarController else { return nil }
        for (index, viewController) in (tabBarController.viewControllers ?? []).enumerated() {
            if let navigationController = viewController as? UINavigationController {
                if let typedVC = navigationController.viewControllers.first(where: { $0 is T }) as? T {
                    tabBarController.selectedIndex = index
                    return typedVC
                }
            } else if let typedVC = viewController as? T {
                tabBarController.selectedIndex = index
                return typedVC
            }
        }
        return nil
    }
    
    @discardableResult
    func getAppTabBarController<T: UIViewController>(vc: T.Type) -> T? {
        guard let tabBarController = appTabBarController else { return nil }
        for viewController in tabBarController.viewControllers ?? [] {
            if let navigationController = viewController as? UINavigationController {
                if let typedVC = navigationController.viewControllers.first(where: { $0 is T }) as? T {
                    return typedVC
                }
            } else if let typedVC = viewController as? T {
                return typedVC
            }
        }
        return nil
    }
    
    func isActiveViewController<T: UIViewController>(ofType type: T.Type) -> Bool {
        guard let tabBarController = appTabBarController else { return false }
        guard let selectedController = tabBarController.selectedViewController else { return false }
        
        if let nav = selectedController as? UINavigationController {
            return nav.viewControllers.contains(where: { $0 is T })
        } else {
            return selectedController is T
        }
    }
    
    func showAppTabBarController(tab: Int) {
        appTabBarController?.selectedIndex = tab
    }
    
}
