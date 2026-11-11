//
//  ConfigurableProtocol.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

protocol ConfigurableProtocol: AnyObject {}

extension ConfigurableProtocol {
    @discardableResult
    func config(_ action: (Self) -> Void) -> Self {
        action(self)
        return self
    }
}

extension NSObject: ConfigurableProtocol {}
