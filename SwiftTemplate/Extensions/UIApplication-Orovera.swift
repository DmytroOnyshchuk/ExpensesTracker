//
//  UIApplication-Toad.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 04.11.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import UIKit

extension UIApplication {
	
	static func showAppTabBarController() {
        let appNavigationController = AppTabBarController().embeddedInAppNavigationController
        AppearanceManager.appNavigationController = appNavigationController
        NotificationCenter.default.post(name: .appLogin, object: nil)
        load(vc: appNavigationController)
	}
	
}
