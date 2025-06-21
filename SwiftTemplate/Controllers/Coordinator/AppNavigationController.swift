//
//  AppNavigationController.swift
//  HealthTracker
//
//  Created by Denis Kuznetsov on 27.11.2020.
//  Copyright © 2020 PeaksCircle. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
    
    override open var prefersStatusBarHidden: Bool {
        return topViewController?.prefersStatusBarHidden ?? false
    }
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
    
}

final class AppNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //navigationBar.isHidden = true
        //view.backgroundColor = .appBlack
    }
    
}

final class AuthNavigationController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .default }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
    }
    
    var previousViewController: UIViewController? {
        guard viewControllers.count > 1 else { return nil }
        return viewControllers[viewControllers.count - 2]
    }
    
}

extension UIViewController {
    
    var embeddedInAppNavigationController: AppNavigationController {
        return AppNavigationController(rootViewController: self)
    }
    
    var embeddedInBaseNavigationController: BaseNavigationController {
        return BaseNavigationController(rootViewController: self)
    }
    
}

extension UINavigationController {
    
    var rootViewController : UIViewController? {
        return viewControllers.first
    }
    
}
