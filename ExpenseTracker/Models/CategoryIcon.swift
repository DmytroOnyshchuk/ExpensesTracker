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
    
    init(name: String, iconColor: IconColor = .yellow) {
        self.name = name
        self.iconColor = iconColor
    }
    
    var image: Image {
        Image(systemName: name)
    }
    
    var color: Color {
        iconColor.color
    }

}
