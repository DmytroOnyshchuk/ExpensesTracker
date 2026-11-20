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

    var balanceChange: Int {
        guard let account, deletedAt == nil, date > account.checkpointDate else { return .zero }
        return signedAmount
    }

    func addToBalance() {
        account?.balance += balanceChange
    }

    func removeFromBalance() {
        account?.balance -= balanceChange
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

    static func shown(of operationType: OperationType) -> Predicate<Transaction> {
        let raw = operationType.rawValue
        return #Predicate<Transaction> { $0.deletedAt == nil && ($0.account == nil || $0.account?.isDisabled == false) && $0.category.operationTypeRaw == raw }
    }

    static func shown(inDirectory uuid: UUID) -> Predicate<Transaction> {
        let parentUuid: UUID? = uuid
        return #Predicate<Transaction> { $0.deletedAt == nil && ($0.account == nil || $0.account?.isDisabled == false) && ($0.category.parentUuid == parentUuid || $0.category.uuid == uuid) }
    }

    static func shown(from start: Date, to end: Date) -> Predicate<Transaction> {
        #Predicate<Transaction> { $0.deletedAt == nil && $0.date >= start && $0.date < end && ($0.account == nil || $0.account?.isDisabled == false) }
    }

    static let withoutAccount = #Predicate<Transaction> { $0.account == nil }

    static func shown(before end: Date) -> Predicate<Transaction> {
        #Predicate<Transaction> { $0.deletedAt == nil && $0.date < end && ($0.account == nil || $0.account?.isDisabled == false) }
    }

    static func shown(of operationType: OperationType, before end: Date) -> Predicate<Transaction> {
        let raw = operationType.rawValue
        return #Predicate<Transaction> { $0.deletedAt == nil && $0.date < end && ($0.account == nil || $0.account?.isDisabled == false) && $0.category.operationTypeRaw == raw }
    }

    static func shown(inDirectory uuid: UUID, before end: Date) -> Predicate<Transaction> {
        let parentUuid: UUID? = uuid
        return #Predicate<Transaction> { $0.deletedAt == nil && $0.date < end && ($0.account == nil || $0.account?.isDisabled == false) && ($0.category.parentUuid == parentUuid || $0.category.uuid == uuid) }
    }

    static func shown(inDirectory uuid: UUID, from start: Date, to end: Date) -> Predicate<Transaction> {
        let parentUuid: UUID? = uuid
        return #Predicate<Transaction> { $0.deletedAt == nil && $0.date >= start && $0.date < end && ($0.account == nil || $0.account?.isDisabled == false) && ($0.category.parentUuid == parentUuid || $0.category.uuid == uuid) }
    }

    static func existing(from start: Date, to end: Date) -> Predicate<Transaction> {
        #Predicate<Transaction> { $0.deletedAt == nil && $0.date >= start && $0.date < end }
    }

    static let inTrashWithOwners = #Predicate<Transaction> { $0.deletedAt != nil || $0.category.deletedAt != nil || $0.account?.deletedAt != nil }
}

extension [Transaction] {
    func of(_ operationType: OperationType) -> [Transaction] {
        filter { $0.operationType == operationType }
    }
}
