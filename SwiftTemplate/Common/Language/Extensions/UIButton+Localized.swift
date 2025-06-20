//
//  UIButton+Localized.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 08.08.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
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
