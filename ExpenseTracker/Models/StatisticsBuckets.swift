//
//  StatisticsBuckets.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 16.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

struct StatisticsBuckets {
    let period: StatisticsPeriod
    let groups: [Date: [Transaction]]
    let first: Date
    let last: Date

    init(period: StatisticsPeriod, transactions: [Transaction], now: Date = Date()) {
        let current = period.interval(containing: now).start
        let groups = Dictionary(grouping: transactions) { period.interval(containing: $0.date).start }

        self.period = period
        self.groups = groups
        self.first = min(groups.keys.min() ?? current, current)
        self.last = max(groups.keys.max() ?? current, current)
    }

    var count: Int {
        index(of: last) + 1
    }

    var starts: [Date] {
        groups.keys.sorted(by: >)
    }

    func transactions(at start: Date) -> [Transaction] {
        groups[start] ?? []
    }

    func start(at index: Int) -> Date {
        period.shifted(first, by: index)
    }

    func index(of start: Date) -> Int {
        Calendar.current.dateComponents([period.component], from: first, to: start).value(for: period.component) ?? .zero
    }

    func clamped(_ date: Date) -> Date {
        min(max(period.interval(containing: date).start, first), last)
    }
}

struct StatisticsRange {
    let period: StatisticsPeriod
    let first: Date
    let last: Date

    init(period: StatisticsPeriod, earliest: Date?, latest: Date?, now: Date = Date()) {
        let current = period.interval(containing: now).start

        self.period = period
        self.first = min(earliest.map { period.interval(containing: $0).start } ?? current, current)
        self.last = max(latest.map { period.interval(containing: $0).start } ?? current, current)
    }

    var count: Int {
        index(of: last) + 1
    }

    func start(at index: Int) -> Date {
        period.shifted(first, by: index)
    }

    func index(of start: Date) -> Int {
        Calendar.current.dateComponents([period.component], from: first, to: start).value(for: period.component) ?? .zero
    }

    func clamped(_ date: Date) -> Date {
        min(max(period.interval(containing: date).start, first), last)
    }
}

enum StatisticsScope: Equatable {
    case operation(OperationType)
    case directory(UUID)

    var predicate: Predicate<Transaction> {
        switch self {
        case let .operation(operationType): Transaction.shown(of: operationType)
        case let .directory(uuid): Transaction.shown(inDirectory: uuid)
        }
    }

    func contains(_ transaction: Transaction) -> Bool {
        switch self {
        case let .operation(operationType): transaction.operationType == operationType
        case let .directory(uuid): transaction.category.parentUuid == uuid || transaction.category.uuid == uuid
        }
    }
}
