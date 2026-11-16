//
//  Budget.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 16.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

struct Budget: Codable {
    var months: [String: Int] = [:]

    func monthly(for month: Date) -> Int {
        let key = Self.key(for: month)
        return months.filter { $0.key <= key }.max { $0.key < $1.key }?.value ?? .zero
    }

    mutating func setMonthly(_ amount: Int, for month: Date) {
        months[Self.key(for: month)] = max(amount, .zero)
    }

    private static func key(for month: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month], from: month)
        return String(format: "%04d-%02d", components.year ?? .zero, components.month ?? .zero)
    }
}
