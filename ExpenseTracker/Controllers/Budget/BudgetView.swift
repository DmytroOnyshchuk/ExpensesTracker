//
//  BudgetView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 14.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

enum BudgetTarget: Identifiable {
    case month
    case category(TransactionCategory)

    var id: String {
        switch self {
        case .month: "month"
        case let .category(category): category.uuid.uuidString
        }
    }

    var title: String {
        switch self {
        case .month: L10n.menuBudget
        case let .category(category): category.name.localized
        }
    }
}

struct BudgetView: View {
    @Environment(\.modelContext) private var modelContext

    @Query private var storedTransactions: [Transaction]
    @Query private var storedCategories: [TransactionCategory]
    @AppStorage(UDKey.budget.rawValue, store: UserDefaults.shared) private var budgetData: Data?

    @State private var target: BudgetTarget?

    private let period = StatisticsPeriod.month

    var body: some View {
        let budget = budget
        let transactions = monthTransactions
        let rows = CategoryBudget.rows(from: transactions, categories: storedCategories.notDeleted)
        let monthProgress = BudgetProgress(spent: transactions.reduce(0) { $0 + $1.amount }, limit: budget.monthly)

        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 24) {
                    MonthBudgetCard(title: monthTitle, progress: monthProgress) {
                        open(.month)
                    }

                    if !rows.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            MenuSectionHeader(title: L10n.menuCategories)

                            VStack(spacing: 0) {
                                ForEach(rows) { row in
                                    CategoryBudgetRow(row: row) {
                                        open(.category(row.category))
                                    }

                                    if row.id != rows.last?.id {
                                        CategoryBudgetDivider()
                                    }
                                }
                            }
                            .glassSurface(
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous),
                                fallback: .appLabel.opacity(0.1)
                            )
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .top)
            }
            .appBackground()
            .navigationTitle(L10n.menuBudget)
            .navigationBarTitleDisplayMode(.inline)
        }
        .overlay {
            if let target {
                BalanceInputPopup(
                    title: target.title,
                    balance: limit(for: target, in: budget),
                    allowsEmpty: true,
                    onCancel: close
                ) { amount in
                    setLimit(amount, for: target)
                    close()
                }
                .id(target.id)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: target?.id)
    }

    private var budget: Budget {
        Budget(jsonData: budgetData) ?? Budget()
    }

    private var monthTitle: String {
        period.title(for: Date())
    }

    private var monthTransactions: [Transaction] {
        let interval = period.interval(containing: Date())
        return storedTransactions.notDeleted.filter { $0.date >= interval.start && $0.date < interval.end }
    }

    private func limit(for target: BudgetTarget, in budget: Budget) -> Int? {
        switch target {
        case .month: budget.monthly
        case let .category(category): category.budget > .zero ? category.budget : nil
        }
    }

    private func setLimit(_ amount: Int, for target: BudgetTarget) {
        withAnimation {
            switch target {
            case .month:
                var budget = budget
                budget.setMonthly(amount)
                budgetData = budget.jsonData()
            case let .category(category):
                category.budget = amount
                try? modelContext.save()
            }
        }
    }

    private func open(_ target: BudgetTarget) {
        FeedbackManager.shared.buttonTapped()
        self.target = target
    }

    private func close() {
        target = nil
    }
}

struct MonthBudgetCard: View {
    let title: String
    let progress: BudgetProgress
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.appLight(14))
                        .foregroundColor(.appLabel)

                    Spacer(minLength: 8)

                    if let status = progress.statusTitle {
                        Text(status)
                            .font(.appRegular(14))
                            .foregroundColor(progress.isExceeded ? .appRed : .appWhite.opacity(0.75))
                            .contentTransition(.numericText())
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(progress.spent.getAmount())
                        .font(.appRegular(26))
                        .foregroundColor(.appWhite)
                        .contentTransition(.numericText())

                    Text(progress.limit.map { "/ \($0.getAmount())" } ?? L10n.budgetNoLimit)
                        .font(.appLight(16))
                        .foregroundColor(.appLabel)
                        .contentTransition(.numericText())

                    Spacer(minLength: 0)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.6)

                if progress.limit != nil {
                    BudgetProgressBar(progress: progress, color: .appPrimary, height: 8)
                }
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
    }
}

struct CategoryBudgetRow: View {
    let row: CategoryBudget
    let action: () -> Void

    private var progress: BudgetProgress { row.progress }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 16) {
                    CategoryIconView(category: row.category)

                    Text(row.category.name.localized)
                        .font(.appLight(18))
                        .foregroundColor(.appWhite)
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(progress.spent.getAmount())
                            .font(.appRegular(16))
                            .foregroundColor(.appWhite)
                            .contentTransition(.numericText())

                        Text(progress.limit.map { "/ \($0.getAmount())" } ?? L10n.budgetNoLimit)
                            .font(.appLight(14))
                            .foregroundColor(.appLabel)
                            .contentTransition(.numericText())
                    }
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .layoutPriority(1)
                }
                .frame(height: 36)

                if progress.limit != nil {
                    BudgetProgressBar(progress: progress, color: row.category.categoryIcon.color, height: 6)

                    if progress.isExceeded, let status = progress.statusTitle {
                        Text(status)
                            .font(.appLight(13))
                            .foregroundColor(.appRed)
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct BudgetProgressBar: View {
    let progress: BudgetProgress
    let color: Color
    let height: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.appLabel.opacity(0.2))

                Capsule()
                    .fill(progress.isExceeded ? Color.appRed : color)
                    .frame(width: fillWidth(in: geometry.size.width))
            }
        }
        .frame(height: height)
        .animation(.easeInOut(duration: 0.3), value: progress.fraction)
    }

    private func fillWidth(in width: CGFloat) -> CGFloat {
        guard progress.spent > .zero else { return .zero }
        return max(width * progress.fraction, height)
    }
}

struct CategoryBudgetDivider: View {
    var body: some View {
        Rectangle()
            .fill(.appLabel.opacity(0.25))
            .frame(height: 0.5)
            .padding(.leading, 64)
            .padding(.trailing, 16)
    }
}

#Preview("Budget") {
    let container = makePreviewModelContainer()
    let categories = (try? container.mainContext.fetch(FetchDescriptor<TransactionCategory>())) ?? []
    for (index, category) in categories.filter({ !$0.isDirectory }).prefix(5).enumerated() {
        container.mainContext.insert(Transaction(amount: (index + 1) * 29000, category: category, date: Date()))
    }

    return BudgetView()
        .modelContainer(container)
}

#Preview("Empty budget") {
    BudgetView()
        .modelContainer(makePreviewModelContainer())
}

#Preview("Budget cards") {
    VStack(spacing: 16) {
        MonthBudgetCard(title: "November 2026", progress: BudgetProgress(spent: 116100, limit: 1500000), action: {})
        MonthBudgetCard(title: "November 2026", progress: BudgetProgress(spent: 71800, limit: 12500), action: {})
        MonthBudgetCard(title: "November 2026", progress: BudgetProgress(spent: 116100, limit: nil), action: {})
    }
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.appMain)
}
