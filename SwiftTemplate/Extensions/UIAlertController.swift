//
//  UIAlertController.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 30.06.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import UIKit

extension UIAlertController {
	
	@discardableResult
	func addAction(withTitle title: String?, style: UIAlertAction.Style = .default, _ handler: (() -> ())? = nil) -> UIAlertController {
		addAction(UIAlertAction(title: title, style: style) { _ in handler?() })
		return self
	}
	
	@discardableResult
	func doneAction(_ action: (() -> ())? = nil) -> UIAlertController {
		return addAction(withTitle: "CLOSE".localized, style: .default, action)
	}
	
	@discardableResult
	func cancelAction(_ action: (() -> ())? = nil) -> UIAlertController {
		return addAction(withTitle: "CANCEL".localized, style: .cancel, action)
	}
	
	@discardableResult
	func noAction(_ action: (() -> ())? = nil) -> UIAlertController {
		return addAction(withTitle: "NO".localized, style: .cancel, action)
	}
	
	@discardableResult
	func yesAction(_ action: (() -> ())? = nil) -> UIAlertController {
		return addAction(withTitle: "YES".localized, style: .destructive, action)
	}
	
	@discardableResult
	func retryAction(_ action: (() -> ())?) -> UIAlertController {
		guard let action = action else { return self }
		return addAction(withTitle: "REPEAT".localized, style: .default, action)
	}
	
}
