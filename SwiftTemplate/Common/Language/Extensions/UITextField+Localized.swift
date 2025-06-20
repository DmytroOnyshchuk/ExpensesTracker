//
//  UITextField+Localized.swift
//  Orovera
//
//  Created by Dmitry Onishchuk on 11.08.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
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
