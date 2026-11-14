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

    var body: some View {
        TabView(selection: $selection) {
            Tab(L10n.tabHome, systemImage: "house.fill", value: AppTab.home) {
                StartView()
                    .undoToast()
            }

            Tab(L10n.tabStatistics, systemImage: "chart.pie.fill", value: AppTab.statistics) {
                NavigationStack {
                    StatisticsView()
                }
                .undoToast()
            }

            Tab(L10n.menuBudget, systemImage: "wallet.bifold", value: AppTab.budget) {
                NavigationStack {
                    BudgetView()
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
    }
}

#Preview {
    RootTabView()
        .modelContainer(makePreviewModelContainer())
}
