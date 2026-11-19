//
//  Budget.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 16.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

enum BudgetPeriod: String, Codable, CaseIterable {
    case month
    case week

    var title: String {
        switch self {
        case .month: L10n.statisticsMonth
        case .week: L10n.budgetWeek
        }
    }
}

struct BudgetSchedule: Codable, Equatable {
    static let monthDays = 1 ... 31

    var period: BudgetPeriod = .month
    var monthDay = 1
    var weekday = Calendar.current.firstWeekday

    static var weekdays: [Int] {
        (0 ..< 7).map { (Calendar.current.firstWeekday - 1 + $0) % 7 + 1 }
    }

    static func weekdayName(_ weekday: Int) -> String {
        let name = Calendar.current.standaloneWeekdaySymbols[(weekday - 1) % 7]
        return name.prefix(1).capitalized + name.dropFirst()
    }

    var startTitle: String {
        switch period {
        case .month: String(monthDay)
        case .week: Self.weekdayName(weekday)
        }
    }

    func start(containing date: Date, calendar: Calendar = .current) -> Date {
        switch period {
        case .month:
            let month = monthStart(of: date, calendar: calendar)
            let start = periodStart(inMonth: month, calendar: calendar)
            return date < start ? periodStart(inMonth: calendar.date(byAdding: .month, value: -1, to: month) ?? month, calendar: calendar) : start
        case .week:
            let day = calendar.startOfDay(for: date)
            let offset = (calendar.component(.weekday, from: day) - weekday + 7) % 7
            return calendar.date(byAdding: .day, value: -offset, to: day) ?? day
        }
    }

    func interval(containing date: Date, calendar: Calendar = .current) -> DateInterval {
        let start = start(containing: date, calendar: calendar)
        return DateInterval(start: start, end: max(shifted(start, by: 1, calendar: calendar), start))
    }

    func shifted(_ start: Date, by value: Int, calendar: Calendar = .current) -> Date {
        switch period {
        case .month:
            let month = monthStart(of: start, calendar: calendar)
            return periodStart(inMonth: calendar.date(byAdding: .month, value: value, to: month) ?? month, calendar: calendar)
        case .week:
            return calendar.date(byAdding: .day, value: value * 7, to: start) ?? start
        }
    }

    func periods(from first: Date, to start: Date, calendar: Calendar = .current) -> Int {
        switch period {
        case .month: calendar.dateComponents([.month], from: monthStart(of: first, calendar: calendar), to: monthStart(of: start, calendar: calendar)).month ?? .zero
        case .week: (calendar.dateComponents([.day], from: first, to: start).day ?? .zero) / 7
        }
    }

    func title(for start: Date, calendar: Calendar = .current) -> String {
        if period == .month, monthDay == 1 {
            return StatisticsPeriod.month.title(for: start)
        }

        let last = calendar.date(byAdding: .day, value: -1, to: shifted(start, by: 1, calendar: calendar)) ?? start
        return "\(start.formatted(.dateTime.day().month(.abbreviated))) – \(last.formatted(.dateTime.day().month(.abbreviated).year()))"
    }

    private func monthStart(of date: Date, calendar: Calendar) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    private func periodStart(inMonth month: Date, calendar: Calendar) -> Date {
        let days = calendar.range(of: .day, in: .month, for: month)?.count ?? 28
        return calendar.date(byAdding: .day, value: min(monthDay, days) - 1, to: month) ?? month
    }
}

struct BudgetRange: Equatable {
    let schedule: BudgetSchedule
    let first: Date
    let last: Date

    init(schedule: BudgetSchedule, earliest: Date?, latest: Date?, now: Date = Date()) {
        let current = schedule.start(containing: now)

        self.schedule = schedule
        self.first = min(earliest.map { schedule.start(containing: $0) } ?? current, current)
        self.last = max(latest.map { schedule.start(containing: $0) } ?? current, current)
    }

    var count: Int {
        index(of: last) + 1
    }

    func start(at index: Int) -> Date {
        schedule.shifted(first, by: index)
    }

    func index(of start: Date) -> Int {
        schedule.periods(from: first, to: start)
    }

    func clamped(_ date: Date) -> Date {
        min(max(schedule.start(containing: date), first), last)
    }
}

struct Budget: Codable {
    var limit: Int?
    var schedule = BudgetSchedule()

    init() {}

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.limit = try? container.decodeIfPresent(Int.self, forKey: .limit)
        self.schedule = (try? container.decodeIfPresent(BudgetSchedule.self, forKey: .schedule)) ?? BudgetSchedule()
    }

    mutating func setLimit(_ amount: Int) {
        limit = amount > .zero ? amount : nil
    }
}
