//
//  OperationType.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 16.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

enum OperationType: String, Codable, CaseIterable, Identifiable {
    case outcome
    case income

    var id: Self { self }

    var toggled: OperationType {
        self == .outcome ? .income : .outcome
    }

    var balanceSign: Int {
        switch self {
        case .outcome: -1
        case .income: 1
        }
    }

    var title: String {
        switch self {
        case .outcome: L10n.statisticsTitle
        case .income: L10n.statisticsIncomeTitle
        }
    }

    var systemImage: String {
        switch self {
        case .outcome: "minus"
        case .income: "plus"
        }
    }

    var enterAmountTitle: String {
        switch self {
        case .outcome: L10n.startviewEnterExpense
        case .income: L10n.startviewEnterIncome
        }
    }

    var todayTitle: String {
        switch self {
        case .outcome: L10n.transactionsListSpentToday
        case .income: L10n.transactionsListReceivedToday
        }
    }

    var yesterdayTitle: String {
        switch self {
        case .outcome: L10n.transactionsListSpentYesterday
        case .income: L10n.transactionsListReceivedYesterday
        }
    }
}
