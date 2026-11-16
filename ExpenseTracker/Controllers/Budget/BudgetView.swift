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
        case .month: L10n.budgetForMonth
        case let .category(category): L10n.budgetForCategory(category.name.localized)
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
        let categories = categories
        let limited = categories.filter { $0.budget > .zero }
        let unlimited = categories.filter { $0.budget <= .zero }
        let spent = spentByCategory

        NavigationStack {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 16) {
                    MonthBudgetCard(title: monthTitle, spent: monthTransactions.reduce(0) { $0 + $1.amount }, limit: monthlyLimit) {
                        open(.month)
                    }

                    if !limited.isEmpty {
                        BudgetSection(leadingTitle: L10n.menuCategories, trailingTitle: L10n.menuBudget) {
                            ForEach(limited, id: \.uuid) { category in
                                CategoryBudgetRow(category: category, spent: spent[category.uuid] ?? .zero) {
                                    open(.category(category))
                                }
                            }
                        }
                    }

                    if !unlimited.isEmpty {
                        BudgetSection(leadingTitle: L10n.budgetNoLimit, trailingTitle: nil) {
                            ForEach(unlimited, id: \.uuid) { category in
                                UnsetCategoryBudgetRow(category: category, spent: spent[category.uuid] ?? .zero) {
                                    open(.category(category))
                                }
                            }
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
                    balance: limit(for: target),
                    allowsEmpty: true,
                    onRemove: limit(for: target) > .zero ? { remove(target) } : nil,
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

    private var monthlyLimit: Int {
        Budget(jsonData: budgetData)?.monthly ?? .zero
    }

    private var monthTitle: String {
        period.title(for: Date())
    }

    private var categories: [TransactionCategory] {
        storedCategories.notDeleted.topLevel.inDisplayOrder
    }

    private var monthTransactions: [Transaction] {
        let interval = period.interval(containing: Date())
        return storedTransactions.notDeleted.filter { $0.date >= interval.start && $0.date < interval.end }
    }

    private var spentByCategory: [UUID: Int] {
        let directories = Set(storedCategories.filter(\.isDirectory).map(\.uuid))

        return monthTransactions.reduce(into: [:]) { result, transaction in
            let category = transaction.category
            let owner = category.parentUuid.flatMap { directories.contains($0) ? $0 : nil } ?? category.uuid
            result[owner, default: .zero] += transaction.amount
        }
    }

    private func limit(for target: BudgetTarget) -> Int {
        switch target {
        case .month: monthlyLimit
        case let .category(category): category.budget
        }
    }

    private func setLimit(_ amount: Int, for target: BudgetTarget) {
        withAnimation {
            switch target {
            case .month:
                var budget = Budget()
                budget.setMonthly(amount)
                budgetData = budget.jsonData()
            case let .category(category):
                category.budget = amount
                try? modelContext.save()
            }
        }
    }

    private func remove(_ target: BudgetTarget) {
        setLimit(.zero, for: target)
        close()
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
    let spent: Int
    let limit: Int
    let action: () -> Void

    private var hasLimit: Bool { limit > .zero }
    private var remaining: Int { limit - spent }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.appLight(12))
                        .foregroundColor(.appLabel)

                    Spacer(minLength: 8)

                    if hasLimit {
                        Text(remaining < .zero ? L10n.budgetExceeded((-remaining).getAmount()) : L10n.budgetLeft(remaining.getAmount()))
                            .font(.appLight(12))
                            .foregroundColor(remaining < .zero ? .appRed : .appWhite.opacity(0.75))
                            .contentTransition(.numericText())
                    }
                }
                .lineLimit(1)
                .minimumScaleFactor(0.7)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(spent.getAmount())
                        .font(.appRegular(22))
                        .foregroundColor(.appWhite)
                        .contentTransition(.numericText())

                    Text(hasLimit ? "/ \(limit.getAmount())" : L10n.budgetNoLimit)
                        .font(.appLight(13))
                        .foregroundColor(.appLabel)
                        .contentTransition(.numericText())

                    Spacer(minLength: 0)
                }
                .lineLimit(1)
                .minimumScaleFactor(0.6)

                if hasLimit {
                    BudgetProgressBar(spent: spent, limit: limit, color: .appPrimary, height: 6)
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

struct BudgetSection<Content: View>: View {
    let leadingTitle: String
    let trailingTitle: String?
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Text(leadingTitle)

                Spacer(minLength: 8)

                if let trailingTitle {
                    Text(trailingTitle)
                }
            }
            .font(.appLight(12))
            .foregroundColor(.appLabel)
            .lineLimit(1)
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 4)

            content
        }
        .padding(.bottom, 6)
        .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: .appLabel.opacity(0.1))
    }
}

struct CategoryBudgetRow: View {
    let category: TransactionCategory
    let spent: Int
    let action: () -> Void

    private var limit: Int { category.budget }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                CategoryIconView(category: category, size: 24)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text(category.name.localized)
                            .font(.appLight(15))
                            .foregroundColor(.appWhite)
                            .lineLimit(1)

                        Spacer(minLength: 8)

                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(spent.getAmount())
                                .font(.appRegular(15))
                                .foregroundColor(.appWhite)
                                .contentTransition(.numericText())

                            Text("/ \(limit.getAmount())")
                                .font(.appLight(12))
                                .foregroundColor(.appLabel)
                                .contentTransition(.numericText())
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .layoutPriority(1)
                    }

                    BudgetProgressBar(spent: spent, limit: limit, color: category.categoryIcon.color, height: 4)

                    if spent > limit {
                        Text(L10n.budgetExceeded((spent - limit).getAmount()))
                            .font(.appLight(11))
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

struct UnsetCategoryBudgetRow: View {
    let category: TransactionCategory
    let spent: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                CategoryIconView(category: category, size: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(category.name.localized)
                        .font(.appLight(15))
                        .foregroundColor(.appWhite)

                    Text(spent.getAmount())
                        .font(.appLight(12))
                        .foregroundColor(.appLabel)
                        .contentTransition(.numericText())
                }
                .lineLimit(1)

                Spacer(minLength: 8)

                Text(L10n.budgetSet)
                    .font(.appRegular(12))
                    .foregroundColor(.appWhite)
                    .lineLimit(1)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(.appLabel.opacity(0.15), in: Capsule())
                    .overlay {
                        Capsule()
                            .stroke(.appLabel.opacity(0.3), lineWidth: 0.5)
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

struct BudgetProgressBar: View {
    let spent: Int
    let limit: Int
    let color: Color
    let height: CGFloat

    private var fraction: Double {
        guard limit > .zero else { return .zero }
        return min(max(spent.asDouble / limit.asDouble, .zero), 1)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.appLabel.opacity(0.2))

                Capsule()
                    .fill(spent > limit ? Color.appRed : color)
                    .frame(width: spent > .zero ? max(geometry.size.width * fraction, height) : .zero)
            }
        }
        .frame(height: height)
        .animation(.easeInOut(duration: 0.3), value: fraction)
    }
}

#Preview("Budget") {
    let container = makePreviewModelContainer()
    let categories = (try? container.mainContext.fetch(FetchDescriptor<TransactionCategory>())) ?? []
    for (index, category) in categories.filter({ !$0.isDirectory }).prefix(5).enumerated() {
        container.mainContext.insert(Transaction(amount: (index + 1) * 29000, category: category, date: Date()))
        category.budget = index < 3 ? 60000 : 0
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
        MonthBudgetCard(title: "November 2026", spent: 116100, limit: 1500000, action: {})
        MonthBudgetCard(title: "November 2026", spent: 71800, limit: 12500, action: {})
        MonthBudgetCard(title: "November 2026", spent: 116100, limit: 0, action: {})
    }
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.appMain)
}
