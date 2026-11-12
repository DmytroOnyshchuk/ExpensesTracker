//
//  StatisticsPeriod.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

enum StatisticsPeriod: CaseIterable, Identifiable {
    case day
    case month
    case year

    var id: Self { self }

    var title: String {
        switch self {
        case .day: L10n.statisticsDay
        case .month: L10n.statisticsMonth
        case .year: L10n.statisticsYear
        }
    }

    var component: Calendar.Component {
        switch self {
        case .day: .day
        case .month: .month
        case .year: .year
        }
    }

    func interval(containing date: Date, calendar: Calendar = .current) -> DateInterval {
        calendar.dateInterval(of: component, for: date) ?? DateInterval(start: date, duration: 0)
    }

    func starts(of transactions: [Transaction], calendar: Calendar = .current) -> [Date] {
        Set(transactions.map { interval(containing: $0.date, calendar: calendar).start }).sorted(by: >)
    }

    func title(for date: Date) -> String {
        let text = switch self {
        case .day: date.formatted(.dateTime.day().month(.wide).year())
        case .month: date.formatted(.dateTime.month(.wide).year())
        case .year: date.formatted(.dateTime.year())
        }
        return text.prefix(1).capitalized + text.dropFirst()
    }
}

struct StatisticsSlice: Identifiable {
    let category: TransactionCategory
    let amount: Int
    let share: Double

    var id: UUID { category.uuid }

    var percent: Int { Int((share * 100).rounded()) }

    static func slices(from transactions: [Transaction], in interval: DateInterval) -> [StatisticsSlice] {
        let matching = transactions.filter { $0.date >= interval.start && $0.date < interval.end }
        let total = matching.reduce(0) { $0 + $1.amount }
        guard total > 0 else { return [] }

        return Dictionary(grouping: matching) { $0.category.uuid }
            .values
            .compactMap { group in
                guard let category = group.first?.category else { return nil }
                let amount = group.reduce(0) { $0 + $1.amount }
                return StatisticsSlice(category: category, amount: amount, share: amount.asDouble / total.asDouble)
            }
            .sorted {
                if $0.amount != $1.amount {
                    return $0.amount > $1.amount
                }
                return $0.category.name.localized < $1.category.name.localized
            }
    }
}
