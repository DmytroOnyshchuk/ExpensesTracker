//
//  HistoryView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext

    @Query(filter: Transaction.visible, sort: \Transaction.date, order: .reverse) private var storedTransactions: [Transaction]

    @StoredSettings private var appSettings

    private var transactions: [Transaction] {
        appSettings.accounting.incomeEnabled ? storedTransactions : storedTransactions.of(.outcome)
    }

    @State private var anchorDate = Date()
    @State private var slideEdge: Edge = .trailing
    @State private var showMonthList = false
    @State private var editedTransaction: Transaction?

    private let period = StatisticsPeriod.month

    var body: some View {
        let starts = period.starts(of: transactions)
        let start = displayedStart(in: starts)
        let interval = period.interval(containing: start)
        let visibleTransactions = transactions.filter { $0.date >= interval.start && $0.date < interval.end }
        let days = days(of: visibleTransactions)

        List {
            monthTitle(start: start, starts: starts)
                .padding(.vertical, 8)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

            if visibleTransactions.isEmpty {
                Text(L10n.transactionsListNoTransactions)
                    .font(.appLight(18))
                    .foregroundColor(.appGray.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } else {
                ForEach(days) { day in
                    Section {
                        ForEach(day.transactions, id: \.id) { transaction in
                            TransactionDetailsRow(transaction: transaction)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editedTransaction = transaction
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        delete(transaction)
                                    } label: {
                                        Label(L10n.remove, systemImage: "trash")
                                    }
                                    .tint(.appRed)
                                }
                                .alignmentGuide(.listRowSeparatorLeading) { _ in 64 }
                                .listRowInsets(EdgeInsets())
                                .listRowBackground(Color.clear)
                                .listRowSeparatorTint(.appSecond)
                                .listRowSeparator(.hidden, edges: .top)
                                .listRowSeparator(
                                    transaction.id == day.transactions.last?.id ? .hidden : .visible,
                                    edges: .bottom
                                )
                        }
                    } header: {
                        TransactionsDayHeader(day: day)
                            .frame(height: 40)
                            .listRowInsets(EdgeInsets())
                    }
                }
            }
        }
        .listStyle(.plain)
        .environment(\.defaultMinListHeaderHeight, 0)
        .scrollContentBackground(.hidden)
        .appBackground()
        .navigationTitle(L10n.historyTitle)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(item: $editedTransaction) { transaction in
            TransactionEdit(transaction: transaction)
        }
    }

    private func monthTitle(start: Date, starts: [Date]) -> some View {
        ZStack {
            Text(period.title(for: start))
                .font(.appRegular(22))
                .foregroundColor(.appPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .id(start)
                .transition(.push(from: slideEdge))
        }
        .padding(.horizontal, 64)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture {
            showMonthList = !starts.isEmpty
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    shiftMonth(by: value.translation.width < 0 ? 1 : -1, from: start, in: starts)
                }
        )
        .overlay {
            HStack {
                monthArrow(systemImage: "chevron.left", shift: -1, start: start, starts: starts)
                Spacer()
                monthArrow(systemImage: "chevron.right", shift: 1, start: start, starts: starts)
            }
            .padding(.horizontal, 16)
        }
        .popover(isPresented: $showMonthList, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
            StatisticsPeriodList(period: period, starts: starts, selected: start) { date in
                showMonthList = false
                select(date, from: start)
            }
            .presentationCompactAdaptation(.popover)
            .legacyPresentationBackground(.appSecond)
        }
    }

    private func monthArrow(systemImage: String, shift: Int, start: Date, starts: [Date]) -> some View {
        PeriodArrowButton(systemImage: systemImage, isEnabled: neighbour(of: start, by: shift, in: starts) != nil) {
            shiftMonth(by: shift, from: start, in: starts)
        }
    }

    private func days(of transactions: [Transaction]) -> [TransactionsDay] {
        let calendar = Calendar.current

        return Dictionary(grouping: transactions) { calendar.startOfDay(for: $0.date) }
            .sorted { $0.key > $1.key }
            .map { date, transactions in
                TransactionsDay(
                    title: date.dayString(.dateTime.day().month(.wide)),
                    transactions: transactions.sorted { $0.date > $1.date }
                )
            }
    }

    private func delete(_ transaction: Transaction) {
        modelContext.deleteWithUndo(transaction)
    }

    private func displayedStart(in starts: [Date]) -> Date {
        let start = period.interval(containing: anchorDate).start
        if starts.isEmpty || starts.contains(start) {
            return start
        }
        return starts.first { $0 < start } ?? starts.last ?? start
    }

    private func shiftMonth(by value: Int, from start: Date, in starts: [Date]) {
        guard let target = neighbour(of: start, by: value, in: starts) else { return }
        FeedbackManager.shared.selectionChanged()
        select(target, from: start)
    }

    private func neighbour(of start: Date, by value: Int, in starts: [Date]) -> Date? {
        value > 0 ? starts.last { $0 > start } : starts.first { $0 < start }
    }

    private func select(_ date: Date, from start: Date) {
        guard date != start else { return }

        slideEdge = date > start ? .trailing : .leading
        withAnimation(.appStandard) {
            anchorDate = date
        }
    }
}

extension HistoryView: Equatable {
    nonisolated static func == (lhs: HistoryView, rhs: HistoryView) -> Bool { true }
}

#Preview("History") {
    let container = makePreviewModelContainer()
    let categories = (try? container.mainContext.fetch(FetchDescriptor<TransactionCategory>())) ?? []
    let calendar = Calendar.current
    for (index, category) in categories.filter({ !$0.isDirectory }).prefix(8).enumerated() {
        let date = calendar.date(byAdding: .day, value: -index * 9, to: Date()) ?? Date()
        container.mainContext.insert(Transaction(amount: (index + 1) * 36000, category: category, date: date))
    }

    return NavigationStack {
        HistoryView()
    }
    .modelContainer(container)
}

#Preview("Empty history") {
    NavigationStack {
        HistoryView()
    }
    .modelContainer(makePreviewModelContainer())
}
