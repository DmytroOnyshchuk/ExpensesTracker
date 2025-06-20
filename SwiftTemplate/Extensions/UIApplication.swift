import UIKit

extension UIApplication {
    
    static var appDelegate: AppDelegate { return shared.delegate as! AppDelegate }
	
	func openSettings() {
		guard let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) else { return }
		UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
	}
    
}

extension UIApplication {
    
    static var windowScene: UIWindowScene {
        for scene in UIApplication.shared.connectedScenes {
            if scene == currentScene {
                return scene as! UIWindowScene
            }
        }
        return shared.connectedScenes.first as! UIWindowScene
    }
    
	var keyWindow: UIWindow? {
		return UIApplication.windowScene.windows.first(where: { $0.isKeyWindow })
	}
	
    static var sceneDelegate: SceneDelegate { windowScene.delegate as! SceneDelegate }
    
    static func load(vc: UIViewController, in window: UIWindow? = nil) {
        let window: UIWindow = UIWindow(windowScene: UIApplication.windowScene)
        sceneDelegate.window = window
        
        if let snapshot = window.snapshotView(afterScreenUpdates: true) {
            window.rootViewController?.view.addSubview(snapshot)
            window.rootViewController = vc
            window.makeKeyAndVisible()
            
            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: {
                snapshot.layer.opacity = 0
            }, completion: { status in
                snapshot.removeFromSuperview()
            })
        } else {
            window.rootViewController = vc
            window.makeKeyAndVisible()
        }
    }
    
  //  static func present(vc: UIViewController, completion: (() -> Void)? = nil) {
   //     sceneDelegate.window?.rootViewController?.present(vc, animated: true, completion: completion)
  //  }
    
}

extension UIApplication {
    
    var visibleViewController: UIViewController? {
        guard let rootViewController = keyWindow?.rootViewController else { return nil }
        return getVisibleViewController(rootViewController)
    }
    
    func showMainTabBarController(withTab tab: Int = 0, animated: Bool = true) {
        guard let visibleVC = visibleViewController else { return }
        if let visibleNC = visibleVC as? UINavigationController {
            visibleNC.popToRootViewController(animated: animated)
        } else {
            visibleVC.navigationController?.popToRootViewController(animated: animated)
        }
        visibleVC.tabBarController?.selectedIndex = tab
    }
    
    private func getVisibleViewController(_ rootViewController: UIViewController) -> UIViewController? {
        if let presentedViewController = rootViewController.presentedViewController {
            return getVisibleViewController(presentedViewController)
        }
        
        if let navigationController = rootViewController as? UINavigationController {
            if let visibleViewController = navigationController.visibleViewController {
                return getVisibleViewController(visibleViewController)
            } else {
                return navigationController
            }
        }
        
        if let tabBarController = rootViewController as? UITabBarController {
            if let selectedViewController = tabBarController.selectedViewController {
                return getVisibleViewController(selectedViewController)
            } else {
                return tabBarController
            }
        }
        
        return rootViewController
    }
    
}
