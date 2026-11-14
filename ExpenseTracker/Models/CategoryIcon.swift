//
//  CategoryIcon.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 29.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import SwiftUI

struct CategoryIcon: Codable {
    var name: String
    var iconColor: IconColor
    var customColorHex: String?

    init(name: String, iconColor: IconColor = .yellow) {
        self.name = name
        self.iconColor = iconColor
    }

    var image: Image {
        Image(systemName: name)
    }

    var color: Color {
        if let customColorHex {
            Color(hex: customColorHex)
        } else {
            iconColor.color
        }
    }

    mutating func select(_ color: IconColor) {
        iconColor = color
        customColorHex = nil
    }

    static func normalizedHex(_ input: String) -> String? {
        let digits = input.trimmingCharacters(in: .whitespaces).uppercased().drop { $0 == "#" }
        guard digits.count == 6, digits.allSatisfy({ $0.isHexDigit && $0.isASCII }) else { return nil }
        return "#" + String(digits)
    }
}
