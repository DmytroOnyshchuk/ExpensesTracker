//
//  String+Localized.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 08.08.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

