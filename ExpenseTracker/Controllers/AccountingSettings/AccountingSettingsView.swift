//
//  AccountingSettingsView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 17.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct AccountingSettingsView: View {
    @StoredSettings private var appSettings

    var body: some View {
        ScrollView(.vertical) {
            VStack(spacing: 0) {
                SettingsToggleRow(title: L10n.accountingExpenses, systemImage: "minus.circle", isOn: .constant(true))
                    .disabled(true)

                MenuRowDivider()

                SettingsToggleRow(title: L10n.accountingIncome, systemImage: "plus.circle", isOn: $appSettings.accounting.incomeEnabled)

                MenuRowDivider()

                SettingsToggleRow(
                    title: L10n.accountingMultipleAccounts,
                    systemImage: "creditcard",
                    isOn: $appSettings.accounting.multipleAccountsEnabled
                )

                MenuRowDivider()

                SettingsToggleRow(title: L10n.menuBudget, systemImage: "wallet.bifold", isOn: $appSettings.accounting.budgetEnabled)
            }
            .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .appBackground()
        .navigationTitle(L10n.menuAccountingSettings)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Accounting settings") {
    NavigationStack {
        AccountingSettingsView()
    }
}
