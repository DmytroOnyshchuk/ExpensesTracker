import UIKit

extension UIApplication {
    func openSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsURL) else { return }
        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
    }
}

extension UIApplication {
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
