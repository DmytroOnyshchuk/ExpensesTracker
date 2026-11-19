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
    @State private var backgroundedAt: Date?
    @State private var sessionId = UUID()
    @StoredSettings private var appSettings
    @Environment(\.scenePhase) private var scenePhase

    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { selection },
            set: { newValue in
                FeedbackManager.shared.buttonTapped()
                if newValue == selection {
                    switch newValue {
                    case .home: homeResetToken += 1
                    case .statistics: statisticsResetToken += 1
                    case .budget: budgetResetToken += 1
                    case .menu: break
                    }
                } else if selection == .statistics {
                    statisticsResetToken += 1
                } else if selection == .budget {
                    budgetResetToken += 1
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
                    MenuView(isActive: selection == .menu)
                }
                .undoToast()
            }
        }
        .id(sessionId)
        .tint(.appPrimary)
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background: backgroundedAt = backgroundedAt ?? Date()
            case .active: returnHomeIfAwayLong()
            default: break
            }
        }
        .onOpenURL(perform: openFile)
        .backupImport(from: $openedFileURL)
    }

    private func returnHomeIfAwayLong() {
        guard let backgroundedAt else { return }
        self.backgroundedAt = nil
        guard Date().timeIntervalSince(backgroundedAt) >= 300 else { return }

        selection = .home
        sessionId = UUID()
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
