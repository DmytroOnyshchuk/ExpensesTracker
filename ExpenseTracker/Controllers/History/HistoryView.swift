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

    @StoredSettings private var appSettings

    @State private var anchorDate = Date()
    @State private var starts: [Date] = []
    @State private var slideEdge: Edge = .trailing
    @State private var showMonthList = false

    private let period = StatisticsPeriod.month

    private var operationType: OperationType? {
        appSettings.accounting.incomeEnabled ? nil : .outcome
    }

    var body: some View {
        let start = displayedStart(in: starts)

        HistoryMonth(interval: period.interval(containing: start), operationType: operationType, starts: starts, onChange: loadStarts) {
            monthTitle(start: start, starts: starts)
        }
        .appBackground()
        .navigationTitle(L10n.historyTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadStarts)
        .onChange(of: operationType) {
            loadStarts()
        }
    }

    private func loadStarts() {
        let operationType = operationType
        starts = modelContext.periodStarts(of: period) { end in operationType.map { Transaction.shown(of: $0, before: end) } ?? Transaction.shown(before: end) }
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
        .padding(.horizontal, 16)
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
        .popover(isPresented: $showMonthList, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
            StatisticsPeriodList(period: period, starts: starts, selected: start) { date in
                showMonthList = false
                select(date, from: start)
            }
            .presentationCompactAdaptation(.popover)
            .legacyPresentationBackground(.appSecond)
        }
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

struct HistoryMonth<Header: View>: View {
    let interval: DateInterval
    let operationType: OperationType?
    let starts: [Date]
    let onChange: () -> Void
    let header: Header

    @Environment(\.modelContext) private var modelContext

    @Query private var storedTransactions: [Transaction]

    @State private var editedTransaction: Transaction?

    init(interval: DateInterval, operationType: OperationType?, starts: [Date], onChange: @escaping () -> Void, @ViewBuilder header: () -> Header) {
        self.interval = interval
        self.operationType = operationType
        self.starts = starts
        self.onChange = onChange
        self.header = header()
        _storedTransactions = Query(filter: Transaction.shown(from: interval.start, to: interval.end), sort: \Transaction.date, order: .reverse)
    }

    var body: some View {
        let visibleTransactions = operationType.map { storedTransactions.of($0) } ?? storedTransactions
        let days = days(of: visibleTransactions)

        List {
            header
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
        .contentMargins(.top, 0, for: .scrollContent)
        .listSectionSpacing(0)
        .fullScreenCover(item: $editedTransaction) { transaction in
            TransactionEdit(transaction: transaction)
        }
        .onChange(of: storedTransactions.count) {
            onChange()
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
}

extension HistoryMonth: Equatable {
    nonisolated static func == (lhs: HistoryMonth, rhs: HistoryMonth) -> Bool { lhs.interval == rhs.interval && lhs.operationType == rhs.operationType && lhs.starts == rhs.starts }
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
