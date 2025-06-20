//
//  UITabBar.swift
//  Orovera
//
//  Created by Dmitry S on 03.11.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import UIKit

extension UITabBar {
	
	func getFrameForTabAt(index: Int) -> CGRect? {
		let frames = subviews
			.compactMap { $0 is UIControl ? $0.frame : nil }
			.sorted { $0.origin.x < $1.origin.x }
		return frames.element(at: index)
	}
	
}
