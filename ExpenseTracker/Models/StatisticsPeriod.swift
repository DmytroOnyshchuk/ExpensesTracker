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

    func average(of transactions: [Transaction], calendar: Calendar = .current) -> Int? {
        guard let first = transactions.map(\.date).min(), let last = transactions.map(\.date).max() else { return nil }

        let from = interval(containing: first, calendar: calendar).start
        let to = interval(containing: max(last, Date()), calendar: calendar).start
        let count = (calendar.dateComponents([component], from: from, to: to).value(for: component) ?? .zero) + 1
        let total = transactions.reduce(0) { $0 + $1.amount }
        return total / max(count, 1)
    }

    func averageTitle(for amount: String) -> String {
        switch self {
        case .day: L10n.statisticsAveragePerDay(amount)
        case .month: L10n.statisticsAveragePerMonth(amount)
        case .year: L10n.statisticsAveragePerYear(amount)
        }
    }

    func title(for date: Date) -> String {
        let text = switch self {
        case .day: date.dayString(.dateTime.day().month(.wide).year())
        case .month: date.formatted(.dateTime.month(.wide).year())
        case .year: date.formatted(.dateTime.year())
        }
        return text.prefix(1).capitalized + text.dropFirst()
    }
}

extension StatisticsPeriod {
    var unitDuration: TimeInterval {
        switch self {
        case .day: 86400
        case .month: 86400 * 30.44
        case .year: 86400 * 365.25
        }
    }

    var defaultVisibleLength: TimeInterval {
        switch self {
        case .day: unitDuration * 30
        case .month: unitDuration * 12
        case .year: unitDuration * 5
        }
    }

    var minVisibleLength: TimeInterval {
        switch self {
        case .day: unitDuration * 7
        case .month: unitDuration * 4
        case .year: unitDuration * 3
        }
    }

    var maxVisibleLength: TimeInterval {
        switch self {
        case .day: unitDuration * 366
        case .month: unitDuration * 120
        case .year: unitDuration * 50
        }
    }

    func amounts(of transactions: [Transaction], calendar: Calendar = .current) -> [Date: Int] {
        transactions.reduce(into: [:]) { result, transaction in
            result[interval(containing: transaction.date, calendar: calendar).start, default: .zero] += transaction.amount
        }
    }

    func boundary(nearest date: Date, calendar: Calendar = .current) -> Date {
        let bucket = interval(containing: date, calendar: calendar)
        return date.timeIntervalSince(bucket.start) < bucket.end.timeIntervalSince(date) ? bucket.start : bucket.end
    }

    func shifted(_ date: Date, by value: Int, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: component, value: value, to: date) ?? date
    }

    func rangeTitle(for range: DateInterval, calendar: Calendar = .current) -> String {
        let first = range.start
        let last = interval(containing: shifted(range.end, by: -1, calendar: calendar), calendar: calendar).start
        guard last > first else { return title(for: first) }

        return "\(rangeLabel(for: first)) – \(rangeLabel(for: last))"
    }

    private func rangeLabel(for date: Date) -> String {
        switch self {
        case .day: date.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year())
        case .month: date.formatted(.dateTime.month(.abbreviated).year())
        case .year: date.formatted(.dateTime.year())
        }
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
