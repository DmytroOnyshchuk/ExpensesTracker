//
//  File.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//


import Foundation
import UIKit

extension UITextField {
    
    @IBInspectable var placeholderLocalizableText: String {
        set(value) {
            self.placeholder = value.localized
        }
        get {
            return self.placeholder ?? ""
        }
    }
    
}
