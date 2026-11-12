//
//  StatisticsView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Charts
import SwiftData
import SwiftUI

struct StatisticsView: View {
    @Query private var transactions: [Transaction]
    @Query private var categories: [TransactionCategory]

    @State private var period: StatisticsPeriod = .month
    @State private var anchorDate = Date()
    @State private var slideEdge: Edge = .trailing
    @State private var showPeriodList = false

    var body: some View {
        let starts = period.starts(of: transactions)
        let start = displayedStart(in: starts)
        let slices = StatisticsSlice.slices(from: transactions, in: period.interval(containing: start))
        let total = slices.reduce(0) { $0 + $1.amount }
        let maxAmount = slices.first?.amount ?? 0

        ScrollView(.vertical) {
            VStack(spacing: 12) {
                periodPicker
                periodTitle(start: start, starts: starts)
                totalLabel(total)

                if slices.isEmpty {
                    Text(L10n.transactionsListNoTransactions)
                        .font(.appLight(18))
                        .foregroundColor(.gray.opacity(0.6))
                        .frame(height: 120)
                } else {
                    StatisticsPieChart(slices: slices)
                        .frame(height: 264)
                        .padding(.horizontal, 48)

                    VStack(spacing: 0) {
                        ForEach(slices) { slice in
                            StatisticsRow(
                                slice: slice,
                                parentName: parentName(of: slice.category),
                                barRatio: maxAmount > 0 ? slice.amount.asDouble / maxAmount.asDouble : 0
                            )
                        }
                    }
                    .padding(.top, 8)
                }
            }
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .background(.appMain)
        .navigationTitle(L10n.statisticsTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var periodPicker: some View {
        HStack(spacing: 0) {
            ForEach(StatisticsPeriod.allCases) { item in
                Button {
                    period = item
                } label: {
                    Text(item.title)
                        .font(.appLight(18))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundColor(item == period ? .appWhite : .appBlue)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background {
                            if item == period {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.appLabel.opacity(0.25))
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.appLabel.opacity(0.4), lineWidth: 1.5)
        }
        .padding(.horizontal, 64)
    }

    private func periodTitle(start: Date, starts: [Date]) -> some View {
        ZStack {
            Text(period.title(for: start))
                .font(.appRegular(22))
                .foregroundColor(.appBlue)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .id(period.interval(containing: start))
                .transition(.push(from: slideEdge))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .clipped()
        .contentShape(Rectangle())
        .onTapGesture {
            showPeriodList = !starts.isEmpty
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    shiftPeriod(by: value.translation.width < 0 ? 1 : -1, from: start, in: starts)
                }
        )
        .popover(isPresented: $showPeriodList, attachmentAnchor: .rect(.bounds), arrowEdge: .top) {
            StatisticsPeriodList(period: period, starts: starts, selected: start) { date in
                showPeriodList = false
                select(date, from: start)
            }
            .presentationCompactAdaptation(.popover)
            .presentationBackground(.appSecond)
        }
    }

    private func totalLabel(_ total: Int) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(L10n.statisticsTotalSpent + ":")
                .font(.appLight(16))

            Text(total.getAmount())
                .font(.appLight(24))
        }
        .foregroundColor(.appWhite)
    }

    private func displayedStart(in starts: [Date]) -> Date {
        let start = period.interval(containing: anchorDate).start
        if starts.isEmpty || starts.contains(start) {
            return start
        }
        return starts.first { $0 < start } ?? starts.last ?? start
    }

    private func shiftPeriod(by value: Int, from start: Date, in starts: [Date]) {
        guard let index = starts.firstIndex(of: start), starts.indices.contains(index - value) else { return }
        select(starts[index - value], from: start)
    }

    private func select(_ date: Date, from start: Date) {
        guard date != start else { return }

        slideEdge = date > start ? .trailing : .leading
        withAnimation(.easeInOut(duration: 0.25)) {
            anchorDate = date
        }
    }

    private func parentName(of category: TransactionCategory) -> String? {
        guard let parent = category.parent(from: categories), parent.isDirectory else { return nil }
        return parent.name.localized
    }
}

struct StatisticsPeriodList: View {
    let period: StatisticsPeriod
    let starts: [Date]
    let selected: Date
    var onSelect: (Date) -> Void

    private static let rowHeight: CGFloat = 48
    private static let maxHeight: CGFloat = 432

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical) {
                LazyVStack(spacing: 0) {
                    ForEach(starts, id: \.self) { date in
                        Button {
                            onSelect(date)
                        } label: {
                            HStack(spacing: 12) {
                                Text(period.title(for: date))
                                    .font(.appLight(18))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)

                                Spacer(minLength: 0)

                                if date == selected {
                                    Image(systemName: "checkmark")
                                }
                            }
                            .foregroundColor(.appWhite)
                            .padding(.horizontal, 20)
                            .frame(height: Self.rowHeight)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .id(date)
                    }
                }
            }
            .onAppear {
                proxy.scrollTo(selected, anchor: .center)
            }
        }
        .frame(width: 280, height: min(starts.count.asCgFloat * Self.rowHeight, Self.maxHeight))
    }
}

struct StatisticsPieChart: View {
    let slices: [StatisticsSlice]

    private static let minLabelShare = 0.08

    var body: some View {
        Chart(slices) { slice in
            SectorMark(angle: .value("Amount", slice.amount), angularInset: 1)
                .foregroundStyle(slice.category.categoryIcon.color)
                .annotation(position: .overlay) {
                    if slice.share >= Self.minLabelShare {
                        Text(slice.category.name.localized)
                            .font(.appRegular(12))
                            .foregroundColor(.appWhite)
                            .lineLimit(1)
                            .frame(maxWidth: 72)
                    }
                }
        }
        .chartLegend(.hidden)
    }
}

struct StatisticsRow: View {
    let slice: StatisticsSlice
    let parentName: String?
    let barRatio: Double

    var body: some View {
        HStack(spacing: 12) {
            slice.category.categoryIcon.image
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 0) {
                Text(slice.category.name.localized)
                    .font(.appLight(18))
                    .lineLimit(1)

                if let parentName {
                    Text(parentName)
                        .font(.appLight(12))
                        .lineLimit(1)
                }
            }

            Spacer(minLength: 8)

            Text("\(slice.percent)%")
                .font(.appRegular(18))
                .frame(width: 56, alignment: .trailing)

            Text(slice.amount.getAmount())
                .font(.appLight(18))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: 110, alignment: .trailing)
        }
        .foregroundColor(.appWhite)
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(alignment: .leading) {
            GeometryReader { geometry in
                Rectangle()
                    .fill(slice.category.categoryIcon.color.opacity(0.8))
                    .frame(width: geometry.size.width * barRatio)
            }
        }
    }
}

#Preview("Statistics") {
    let container = makePreviewModelContainer()
    let categories = (try? container.mainContext.fetch(FetchDescriptor<TransactionCategory>())) ?? []
    for (index, category) in categories.filter({ !$0.isDirectory }).prefix(7).enumerated() {
        container.mainContext.insert(Transaction(amount: (7 - index) * 125000, category: category))
    }

    return NavigationStack {
        StatisticsView()
    }
    .modelContainer(container)
}

#Preview("Empty statistics") {
    NavigationStack {
        StatisticsView()
    }
    .modelContainer(makePreviewModelContainer())
}

#Preview("Statistics row") {
    StatisticsRow(
        slice: StatisticsSlice(
            category: TransactionCategory(name: "Groceries", categoryIcon: CategoryIcon(name: "cart", iconColor: .green)),
            amount: 1248500,
            share: 0.16
        ),
        parentName: "Food",
        barRatio: 0.53
    )
    .background(.appMain)
}
