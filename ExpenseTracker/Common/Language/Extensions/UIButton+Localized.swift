//
//  UIButton+Localized.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    @IBInspectable var localizableTitle: String {
        set(value) {
            setTitle(value.localized, for: .normal)
        }
        get {
            titleLabel?.text ?? ""
        }
    }
}
