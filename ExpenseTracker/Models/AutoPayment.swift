//
//  AutoPayment.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 17.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import RealmSwift

enum AutoPaymentPeriodUnit: String, Codable, CaseIterable, Identifiable {
    case day
    case week
    case month
    case year

    var id: Self { self }

    var calendarComponent: Calendar.Component {
        switch self {
        case .day: .day
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
    }

    private var formatterUnit: NSCalendar.Unit {
        switch self {
        case .day: .day
        case .week: .weekOfMonth
        case .month: .month
        case .year: .year
        }
    }

    private func components(_ count: Int) -> DateComponents {
        switch self {
        case .day: DateComponents(day: count)
        case .week: DateComponents(weekOfMonth: count)
        case .month: DateComponents(month: count)
        case .year: DateComponents(year: count)
        }
    }

    func title(count: Int) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = formatterUnit
        return formatter.string(from: components(count)) ?? "\(count) \(rawValue)"
    }

    func name(count: Int) -> String {
        let title = title(count: count)
        let name = title.components(separatedBy: .decimalDigits).joined().trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? title : name
    }
}

final class AutoPayment: Object, Identifiable {
    @Persisted(primaryKey: true) var uuid: UUID = UUID()
    @Persisted var amount: Int = 0
    @Persisted var note: String?
    @Persisted var category: TransactionCategory?
    @Persisted var account: Account?
    @Persisted var periodCount: Int = 1
    @Persisted var periodUnitRaw: String = AutoPaymentPeriodUnit.month.rawValue
    @Persisted var startDate: Date = Date()
    @Persisted var completedPayments: Int = 0
    @Persisted var deletedAt: Date?

    var id: UUID { uuid }

    convenience init(amount: Int, category: TransactionCategory, account: Account? = nil, periodCount: Int = 1, periodUnit: AutoPaymentPeriodUnit = .month, startDate: Date = Date(), note: String? = nil) {
        self.init()
        self.amount = amount
        self.category = category.live
        self.account = account?.live
        self.periodCount = periodCount
        self.periodUnitRaw = periodUnit.rawValue
        self.startDate = startDate
        self.note = note
    }

    var periodUnit: AutoPaymentPeriodUnit {
        get { AutoPaymentPeriodUnit(rawValue: periodUnitRaw) ?? .month }
        set { periodUnitRaw = newValue.rawValue }
    }

    var periodTitle: String {
        periodUnit.title(count: periodCount)
    }

    var operationType: OperationType {
        category?.operationType ?? .outcome
    }

    var nextDate: Date {
        Calendar.current.date(byAdding: periodUnit.calendarComponent, value: max(periodCount, 1) * completedPayments, to: startDate) ?? startDate
    }

    var displayAmount: String {
        operationType == .income ? "+" + amount.getAmount() : amount.getAmount()
    }

    func skipPayments(before date: Date) {
        completedPayments = .zero
        while nextDate < date {
            completedPayments += 1
        }
    }
}

extension AutoPayment {
    static let inTrash: (Query<AutoPayment>) -> Query<Bool> = { $0.deletedAt != nil }
    static let active: (Query<AutoPayment>) -> Query<Bool> = { $0.deletedAt == nil && $0.category != nil && $0.category.deletedAt == nil && ($0.account == nil || $0.account.deletedAt == nil) }
}

extension Sequence<AutoPayment> {
    var inDisplayOrder: [AutoPayment] {
        sorted { $0.nextDate < $1.nextDate }
    }
}

extension Realm {
    func runAutoPayments(now: Date = Date()) {
        let due = Array(objects(AutoPayment.self).where(AutoPayment.active)).filter { $0.amount > 0 && $0.nextDate <= now }
        guard !due.isEmpty else { return }

        update {
            for autoPayment in due {
                guard let category = autoPayment.category else { continue }

                while autoPayment.nextDate <= now {
                    add(Transaction(amount: autoPayment.amount, category: category, date: autoPayment.nextDate, note: autoPayment.note, account: autoPayment.account))
                    autoPayment.completedPayments += 1
                }
            }
        }
    }
}
