//
//  UILabel+Localized.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    @IBInspectable var localizableText: String {
        set(value) {
            text = value.localized
        }
        get {
            text ?? ""
        }
    }
}
