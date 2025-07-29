//
//  NSAttributedString.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 28.06.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import Foundation

extension NSAttributedString {
	
	func height(withConstrainedWidth width: CGFloat) -> CGFloat {
		let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
		let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
		
		return ceil(boundingBox.height)
	}
	
	func width(withConstrainedHeight height: CGFloat) -> CGFloat {
		let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
		let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
		
		return ceil(boundingBox.width)
	}
	
}
