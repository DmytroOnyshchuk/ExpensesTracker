//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Transaction {
    #Index<Transaction>([\.date], [\.deletedAt, \.date])

    var id: UUID = UUID()
    var amount: Int = 0
    var date: Date = Date()
    var note: String?
    var category: TransactionCategory
    var deletedAt: Date?
    var account: Account?

    init(amount: Int, category: TransactionCategory, date: Date = Date(), note: String? = nil, account: Account? = nil) {
        self.id = UUID()
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.account = account
    }

    var operationType: OperationType {
        category.operationType
    }

    var signedAmount: Int {
        amount * operationType.balanceSign
    }

    var displayAmount: String {
        operationType == .income ? "+" + amount.getAmount() : amount.getAmount()
    }
}

extension Transaction {
    static let notDeleted = #Predicate<Transaction> { $0.deletedAt == nil }
    static let visible = #Predicate<Transaction> { $0.deletedAt == nil && ($0.account == nil || $0.account?.isDisabled == false) }
    static let inTrash = #Predicate<Transaction> { $0.deletedAt != nil }

    static func listed(of operationType: OperationType, since start: Date) -> Predicate<Transaction> {
        let raw = operationType.rawValue
        return #Predicate<Transaction> { $0.deletedAt == nil && $0.date >= start && ($0.account == nil || $0.account?.isDisabled == false) && $0.category.operationTypeRaw == raw }
    }

    static func listed(of operationType: OperationType) -> Predicate<Transaction> {
        let raw = operationType.rawValue
        return #Predicate<Transaction> { $0.deletedAt == nil && ($0.account == nil || $0.account?.isDisabled == false) && $0.category.operationTypeRaw == raw }
    }

    static func recorded(of operationType: OperationType, in interval: DateInterval) -> Predicate<Transaction> {
        let raw = operationType.rawValue
        let start = interval.start
        let end = interval.end
        return #Predicate<Transaction> { $0.deletedAt == nil && $0.date >= start && $0.date < end && $0.category.operationTypeRaw == raw }
    }

    static func counted(for accountUuid: UUID, after checkpointDate: Date, of operationType: OperationType) -> Predicate<Transaction> {
        let raw = operationType.rawValue
        return #Predicate<Transaction> { $0.deletedAt == nil && $0.date > checkpointDate && $0.account?.uuid == accountUuid && $0.category.operationTypeRaw == raw }
    }

    static let inTrashWithOwners = #Predicate<Transaction> { $0.deletedAt != nil || $0.category.deletedAt != nil || $0.account?.deletedAt != nil }
}

extension [Transaction] {
    func of(_ operationType: OperationType) -> [Transaction] {
        filter { $0.operationType == operationType }
    }

    func ascendingSlice(in interval: DateInterval) -> [Transaction] {
        Array(self[firstIndex(notBefore: interval.start) ..< firstIndex(notBefore: interval.end)])
    }

    private func firstIndex(notBefore date: Date) -> Int {
        var low = startIndex
        var high = endIndex
        while low < high {
            let middle = (low + high) / 2
            if self[middle].date < date {
                low = middle + 1
            } else {
                high = middle
            }
        }
        return low
    }
}
