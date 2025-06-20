//
//  File.swift
//  Orovera
//
//  Created by Dmitry Onishchuk on 15.08.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation
import UIKit

extension GrowingTextView {
    
    @IBInspectable var placeholderLocalizableText: String {
        set(value) {
            self.placeholder = value.localized
        }
        get {
            return self.placeholder ?? ""
        }
    }
    
}
