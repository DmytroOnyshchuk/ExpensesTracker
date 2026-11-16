//
//  Budget.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 16.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

struct Budget: Codable {
    var monthly: Int?

    mutating func setMonthly(_ amount: Int) {
        monthly = amount > .zero ? amount : nil
    }
}
