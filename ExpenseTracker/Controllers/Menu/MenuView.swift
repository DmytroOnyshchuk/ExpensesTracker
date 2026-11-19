//
//  MenuView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

enum MenuItem: CaseIterable, Identifiable {
    case categories
    case settings
    case accounting
    case autoPayments
    case backups
    case language
    case about
    case trash

    var id: Self { self }

    var title: String {
        switch self {
        case .categories: L10n.menuCategories
        case .settings: L10n.menuSettings
        case .accounting: L10n.menuAccountingSettings
        case .autoPayments: L10n.menuAutopayments
        case .backups: L10n.menuBackups
        case .language: L10n.menuLanguage
        case .about: L10n.menuAbout
        case .trash: L10n.menuTrash
        }
    }

    var systemImage: String {
        switch self {
        case .categories: "square.grid.2x2"
        case .settings: "slider.horizontal.3"
        case .accounting: "checklist"
        case .autoPayments: "repeat"
        case .backups: "externaldrive"
        case .language: "globe"
        case .about: "info.circle"
        case .trash: "trash"
        }
    }
}

enum MenuSection: CaseIterable, Identifiable {
    case general
    case data
    case app

    var id: Self { self }

    var title: String {
        switch self {
        case .general: L10n.menuSectionGeneral
        case .data: L10n.menuSectionData
        case .app: L10n.menuSectionApp
        }
    }

    var items: [MenuItem] {
        switch self {
        case .general: [.settings, .accounting, .categories, .autoPayments]
        case .data: [.backups, .trash]
        case .app: [.language, .about]
        }
    }
}

struct MenuView: View {
    @Query(filter: Transaction.notDeleted) private var transactions: [Transaction]
    @Query(filter: Account.notDeleted) private var accounts: [Account]
    @StoredSettings private var appSettings

    @State private var showStatistics = false
    @State private var showCategories = false
    @State private var showSettings = false
    @State private var showAccountingSettings = false
    @State private var showAutoPayments = false
    @State private var showBackups = false
    @State private var showAbout = false
    @State private var showTrash = false

    private let period = StatisticsPeriod.month

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    MenuSectionHeader(title: L10n.tabStatistics)

                    MenuSpentCard(title: spentTitle, amount: spentAmount, balance: balance, action: openStatistics)
                }

                ForEach(MenuSection.allCases) { section in
                    VStack(alignment: .leading, spacing: 8) {
                        MenuSectionHeader(title: section.title)

                        VStack(spacing: 0) {
                            ForEach(section.items) { item in
                                MenuRow(title: item.title, systemImage: item.systemImage) {
                                    open(item)
                                }

                                if item != section.items.last {
                                    MenuRowDivider()
                                }
                            }
                        }
                        .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .appBackground()
        .navigationTitle(L10n.menuTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showStatistics) {
            StatisticsView()
        }
        .navigationDestination(isPresented: $showCategories) {
            CategoriesEdit()
        }
        .navigationDestination(isPresented: $showSettings) {
            SettingsView()
        }
        .navigationDestination(isPresented: $showAccountingSettings) {
            AccountingSettingsView()
        }
        .navigationDestination(isPresented: $showAutoPayments) {
            AutoPaymentsView()
        }
        .navigationDestination(isPresented: $showBackups) {
            BackupsView()
        }
        .navigationDestination(isPresented: $showAbout) {
            AboutView()
        }
        .navigationDestination(isPresented: $showTrash) {
            TrashView()
        }
    }

    private var spentTitle: String {
        L10n.menuSpentInMonth(Date().formatted(.dateTime.month(.wide)))
    }

    private var spentAmount: Int {
        let interval = period.interval(containing: Date())
        return transactions
            .of(.outcome)
            .filter { $0.date >= interval.start && $0.date < interval.end }
            .reduce(0) { $0 + $1.amount }
    }

    private var balance: Int? {
        guard appSettings.accounting.multipleAccountsEnabled, !accounts.isEmpty else { return nil }
        return accounts.enabled.total(in: transactions)
    }

    private func open(_ item: MenuItem) {
        FeedbackManager.shared.buttonTapped()
        switch item {
        case .categories: showCategories = true
        case .settings: showSettings = true
        case .accounting: showAccountingSettings = true
        case .autoPayments: showAutoPayments = true
        case .backups: showBackups = true
        case .language: UIApplication.shared.openSettings()
        case .about: showAbout = true
        case .trash: showTrash = true
        }
    }

    private func openStatistics() {
        FeedbackManager.shared.buttonTapped()
        showStatistics = true
    }
}

struct MenuSpentCard: View {
    let title: String
    let amount: Int
    let balance: Int?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.appLight(14))
                        .foregroundColor(.appLabel)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(amount.getAmount())
                        .font(.appRegular(26))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .contentTransition(.numericText())

                    if let balance {
                        HStack(spacing: 6) {
                            Text(L10n.startviewBalance)
                                .font(.appLight(14))
                                .foregroundColor(.appLabel)

                            Text(balance.getAmount())
                                .font(.appRegular(14))
                                .foregroundColor(balance < 0 ? .appRed : .appWhite.opacity(0.75))
                                .contentTransition(.numericText())
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    }
                }

                Spacer(minLength: 8)

                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.appPrimary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .glassSurface(
                in: RoundedRectangle(cornerRadius: 18, style: .continuous),
                tint: .appPrimary.opacity(0.15),
                isInteractive: true,
                fallback: .appPrimary.opacity(0.15)
            )
            .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
        .animation(.default, value: balance)
    }
}

struct MenuSectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.appMedium(14))
            .foregroundColor(.appLabel)
            .lineLimit(1)
            .padding(.horizontal, 16)
    }
}

struct MenuRowDivider: View {
    var body: some View {
        Rectangle()
            .fill(.appLabel.opacity(0.25))
            .frame(height: 0.5)
            .padding(.leading, 52)
            .padding(.trailing, 16)
    }
}

struct MenuRow: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            MenuRowLabel(title: title, systemImage: systemImage)
        }
        .buttonStyle(.plain)
    }
}

struct MenuRowLabel: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 17))
                .foregroundColor(.appPrimary)
                .frame(width: 24)

            Text(title)
                .font(.appLight(16))
                .foregroundColor(.appWhite)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.appLabel)
        }
        .padding(.horizontal, 16)
        .frame(height: 46)
        .contentShape(Rectangle())
    }
}

#Preview("Menu") {
    let container = makePreviewModelContainer()
    let categories = (try? container.mainContext.fetch(FetchDescriptor<TransactionCategory>())) ?? []
    for (index, category) in categories.filter({ !$0.isDirectory }).prefix(4).enumerated() {
        container.mainContext.insert(Transaction(amount: (index + 1) * 29000, category: category, date: Date()))
    }

    return NavigationStack {
        MenuView()
    }
    .modelContainer(container)
}

#Preview("Empty menu") {
    NavigationStack {
        MenuView()
    }
    .modelContainer(makePreviewModelContainer())
}
