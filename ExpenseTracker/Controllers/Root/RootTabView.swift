//
//  RootTabView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 14.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

enum AppTab: Hashable {
    case home
    case statistics
    case budget
    case menu
}

struct RootTabView: View {
    @State private var selection: AppTab = .home
    @State private var openedFileURL: URL?
    @State private var homeResetToken: Int = .zero
    @State private var statisticsResetToken: Int = .zero
    @State private var budgetResetToken: Int = .zero
    @StoredSettings private var appSettings

    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { selection },
            set: { newValue in
                if newValue == selection {
                    switch newValue {
                    case .home: homeResetToken += 1
                    case .statistics: statisticsResetToken += 1
                    case .budget: budgetResetToken += 1
                    case .menu: break
                    }
                }
                selection = newValue
            }
        )
    }

    var body: some View {
        TabView(selection: tabSelection) {
            Tab(L10n.tabHome, systemImage: "house.fill", value: AppTab.home) {
                StartView(resetToken: homeResetToken)
                    .undoToast()
            }

            Tab(L10n.tabStatistics, systemImage: "chart.pie.fill", value: AppTab.statistics) {
                NavigationStack {
                    StatisticsView(resetToken: statisticsResetToken)
                }
                .undoToast()
            }

            if appSettings.accounting.budgetEnabled {
                Tab(L10n.menuBudget, systemImage: "wallet.bifold", value: AppTab.budget) {
                    BudgetView(resetToken: budgetResetToken)
                }
            }

            Tab(L10n.menuTitle, systemImage: "list.dash", value: AppTab.menu) {
                NavigationStack {
                    MenuView()
                }
                .undoToast()
            }
        }
        .tint(.appPrimary)
        .background {
            AccountBalanceTracker()
        }
        .onOpenURL(perform: openFile)
        .backupImport(from: $openedFileURL)
    }

    private func openFile(_ url: URL) {
        guard url.isFileURL else { return }
        openedFileURL = url
    }
}

#Preview {
    RootTabView()
        .modelContainer(makePreviewModelContainer())
}
