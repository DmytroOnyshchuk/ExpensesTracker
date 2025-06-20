//
//  UILabel+Localized.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 08.08.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    @IBInspectable var localizableText: String {
        set(value) {
            self.text = value.localized
        }
        get {
            return self.text ?? ""
        }
    }
    
}

