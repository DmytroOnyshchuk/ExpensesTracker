//
//  File.swift
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
			self.setTitle(value.localized, for: .normal)
        }
        get {
            return titleLabel?.text ?? ""
        }
    }
    
}
