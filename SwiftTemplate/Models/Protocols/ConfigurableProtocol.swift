//
//  ConfigurableProtocol.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 11.07.2023.
//  Copyright © 2023 PeaksCircle. All rights reserved.
//

import Foundation

protocol ConfigurableProtocol: AnyObject {
	
}

extension ConfigurableProtocol {
	
	@discardableResult
	func config(_ action: (Self) -> ()) -> Self {
		action(self)
		return self
	}
	
}

extension NSObject: ConfigurableProtocol {
	
}

