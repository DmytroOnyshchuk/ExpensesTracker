//
//  UIStoryboard.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 29.08.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import UIKit

extension UIStoryboard {
	
	class func loadStoryboard<T: UIViewController>(_ viewController: T.Type) -> UIStoryboard {
		return UIStoryboard.init(name: viewController.className, bundle: nil)
	}
}
