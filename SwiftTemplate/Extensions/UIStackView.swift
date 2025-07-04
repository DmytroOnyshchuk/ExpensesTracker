//
//  UIStackView.swift
//  Orovera
//
//  Created by Dmitry S on 27/8/21.
//

import UIKit

extension UIStackView {
	
	func addArrangedSubviews(_ views: [UIView]) {
		views.forEach { addArrangedSubview($0) }
	}
	
	func addArrangedSubviews(_ views: UIView...) {
		views.forEach { addArrangedSubview($0) }
	}
	
	func removeAllArrangedSubviews() {
		let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
			self.removeArrangedSubview(subview)
			return allSubviews + [subview]
		}
		// Deactivate all constraints
		NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
		// Remove the views from self
		removedSubviews.forEach({ $0.removeFromSuperview() })
	}
    
}
