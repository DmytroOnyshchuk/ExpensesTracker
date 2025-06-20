//
//  BaseNavigationController.swift
//  Orovera
//
//  Created by Dmitry S on 26/8/21.
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
