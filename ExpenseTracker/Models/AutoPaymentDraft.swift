//
//  AutoPaymentDraft.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 17.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

struct AutoPaymentDraft: Equatable {
    static let periodCounts = 1 ... 99

    var operationType: OperationType
    var category: TransactionCategory?
    var amount: Int
    var account: Account?
    var periodCount: Int
    var periodUnit: AutoPaymentPeriodUnit
    var startDate: Date
    var note: String

    var canSave: Bool { amount != .zero && category != nil }

    var periodTitle: String {
        periodUnit.title(count: periodCount)
    }

    init(account: Account?) {
        self.operationType = .outcome
        self.amount = .zero
        self.account = account
        self.periodCount = 1
        self.periodUnit = .month
        self.startDate = Calendar.current.startOfDay(for: Date())
        self.note = String()
    }

    init(_ autoPayment: AutoPayment) {
        self.operationType = autoPayment.operationType
        self.category = autoPayment.category
        self.amount = autoPayment.amount
        self.account = autoPayment.account
        self.periodCount = autoPayment.periodCount
        self.periodUnit = autoPayment.periodUnit
        self.startDate = autoPayment.startDate
        self.note = autoPayment.note ?? String()
    }

    mutating func setOperationType(_ newValue: OperationType) {
        operationType = newValue
        if category?.operationType != newValue {
            category = nil
        }
    }

    func makeAutoPayment() -> AutoPayment? {
        guard let category else { return nil }
        let autoPayment = AutoPayment(amount: amount, category: category, account: account, periodCount: periodCount, periodUnit: periodUnit, startDate: startDate, note: note.isBlank ? nil : note)
        autoPayment.skipPayments(before: Calendar.current.startOfDay(for: Date()))
        return autoPayment
    }

    func apply(to autoPayment: AutoPayment) {
        let isScheduleChanged = autoPayment.startDate != startDate || autoPayment.periodCount != periodCount || autoPayment.periodUnit != periodUnit

        autoPayment.category = category?.live
        autoPayment.amount = amount
        autoPayment.account = account?.live
        autoPayment.periodCount = periodCount
        autoPayment.periodUnit = periodUnit
        autoPayment.startDate = startDate
        autoPayment.note = note.isBlank ? nil : note

        if isScheduleChanged {
            autoPayment.skipPayments(before: Date())
        }
    }

    static func == (lhs: AutoPaymentDraft, rhs: AutoPaymentDraft) -> Bool {
        lhs.operationType == rhs.operationType && lhs.category?.uuid == rhs.category?.uuid && lhs.amount == rhs.amount && lhs.account?.uuid == rhs.account?.uuid && lhs.periodCount == rhs.periodCount && lhs.periodUnit == rhs.periodUnit && lhs.startDate == rhs.startDate && lhs.note == rhs.note
    }
}
