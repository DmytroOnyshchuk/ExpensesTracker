//
//  Account.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import RealmSwift

enum AccountType: String, Codable {
    case wallet
    case bank
}

final class Account: Object, Identifiable {
    @Persisted(primaryKey: true) var uuid: UUID = UUID()
    @Persisted var name: String = String()
    @Persisted var amount: Int = 0
    @Persisted var checkpointDate: Date = Date()
    @Persisted var sortIndex: Int = 0
    @Persisted var deletedAt: Date?
    @Persisted var typeRaw: String = AccountType.wallet.rawValue
    @Persisted var isDisabled: Bool = false

    var id: UUID { uuid }

    var type: AccountType {
        get { AccountType(rawValue: typeRaw) ?? .wallet }
        set { typeRaw = newValue.rawValue }
    }

    convenience init(name: String, amount: Int = .zero, checkpointDate: Date = Date(), sortIndex: Int = .zero) {
        self.init()
        self.name = name
        self.amount = amount
        self.checkpointDate = checkpointDate
        self.sortIndex = sortIndex
    }

    func current(in transactions: [Transaction]) -> Int {
        let uuid = uuid
        let checkpointDate = checkpointDate
        let change = transactions
            .filter { $0.account?.uuid == uuid && $0.date > checkpointDate }
            .reduce(0) { $0 + $1.signedAmount }
        return amount + change
    }

    func setAmount(_ newAmount: Int) {
        amount = newAmount
        checkpointDate = Date()
    }
}

extension Account {
    static let notDeleted: (Query<Account>) -> Query<Bool> = { $0.deletedAt == nil }
    static let available: (Query<Account>) -> Query<Bool> = { $0.deletedAt == nil && $0.isDisabled == false }
    static let inTrash: (Query<Account>) -> Query<Bool> = { $0.deletedAt != nil }
}

extension Sequence<Account> {
    var enabled: [Account] {
        filter { !$0.isDisabled }
    }

    var inDisplayOrder: [Account] {
        sorted { $0.sortIndex < $1.sortIndex }
    }

    var nextSortIndex: Int {
        (map(\.sortIndex).max() ?? -1) + 1
    }

    func total(in transactions: [Transaction]) -> Int {
        reduce(0) { $0 + $1.current(in: transactions) }
    }
}
