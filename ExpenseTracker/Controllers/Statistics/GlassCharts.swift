//
//  GlassCharts.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 14.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Charts
import SwiftUI

enum StatisticsChartStyle: String, CaseIterable, Identifiable {
    case pie
    case bars
    case line

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .pie: "chart.pie.fill"
        case .bars: "chart.bar.fill"
        case .line: "chart.line.uptrend.xyaxis"
        }
    }
}

struct StatisticsChartPoint: Identifiable {
    let start: Date
    let amount: Int
    let total: Int

    var id: Date { start }

    var value: Double { amount.asDouble / 100 }

    var totalValue: Double { total.asDouble / 100 }
}

extension StatisticsPeriod {
    var chartComponent: Calendar.Component {
        switch self {
        case .day: .hour
        case .month: .day
        case .year: .month
        }
    }

    var chartAxisFormat: Date.FormatStyle {
        switch self {
        case .day: .dateTime.hour()
        case .month: .dateTime.day()
        case .year: .dateTime.month(.abbreviated)
        }
    }

    func chartPoints(
        of transactions: [Transaction],
        in interval: DateInterval,
        calendar: Calendar = .current
    ) -> [StatisticsChartPoint] {
        let component = chartComponent
        var amounts: [Date: Int] = [:]
        for transaction in transactions where transaction.date >= interval.start && transaction.date < interval.end {
            let start = calendar.dateInterval(of: component, for: transaction.date)?.start ?? transaction.date
            amounts[start, default: .zero] += transaction.amount
        }

        var result: [StatisticsChartPoint] = []
        var total = 0
        var date = interval.start
        while date < interval.end {
            let amount = amounts[date] ?? .zero
            total += amount
            result.append(StatisticsChartPoint(start: date, amount: amount, total: total))
            guard let next = calendar.date(byAdding: component, value: 1, to: date), next > date else { break }
            date = next
        }
        return result
    }
}

struct ChartStylePicker: View {
    @Binding var selection: StatisticsChartStyle

    var body: some View {
        HStack(spacing: 0) {
            ForEach(StatisticsChartStyle.allCases) { style in
                Button {
                    selection = style
                } label: {
                    Image(systemName: style.systemImage)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(style == selection ? .appWhite : .appPrimary)
                        .frame(width: 40, height: 32)
                        .background {
                            if style == selection {
                                Capsule()
                                    .fill(.appLabel.opacity(0.25))
                            }
                        }
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .glassSurface(in: Capsule(), fallback: .clear)
        .overlay {
            if !LiquidGlass.isAvailable {
                Capsule()
                    .stroke(.appLabel.opacity(0.4), lineWidth: 1.5)
            }
        }
        .sensoryFeedback(.selection, trigger: selection)
    }
}

struct DonutArc: Shape {
    var startAngle: Angle
    var endAngle: Angle
    var innerRadius: CGFloat
    var outerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.addArc(center: center, radius: outerRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.addArc(center: center, radius: innerRadius, startAngle: endAngle, endAngle: startAngle, clockwise: true)
        path.closeSubpath()
        return path
    }
}

struct GlassDonutChart: View {
    let slices: [StatisticsSlice]

    @State private var progress: CGFloat = 0

    private static let minLabelShare = 0.06
    private static let innerRatio: CGFloat = 0.56
    private static let innerBandRatio: CGFloat = 0.24
    private static let badgeSize: CGFloat = 40
    private static let badgeDistance: CGFloat = 30

    private struct Segment: Identifiable {
        let slice: StatisticsSlice
        let start: Double
        let end: Double

        var id: UUID { slice.id }

        var color: Color { slice.category.categoryIcon.color }

        var middle: Double { (start + end) / 2 * .pi / 180 }
    }

    private var segments: [Segment] {
        var angle = -90.0
        return slices.map { slice in
            let end = angle + slice.share * 360
            defer { angle = end }
            return Segment(slice: slice, start: angle, end: end)
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let outer = max(min(size.width / 2 - 54, size.height / 2 - 70), 40)
            let inner = outer * Self.innerRatio
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let reach = outer + 40
            let segments = segments

            ZStack {
                ZStack {
                    ring(segments, inner: inner, outer: outer)
                        .blur(radius: 14)
                        .opacity(0.45)

                    ring(segments, inner: inner, outer: outer)

                    DonutArc(
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270),
                        innerRadius: inner,
                        outerRadius: inner + (outer - inner) * Self.innerBandRatio
                    )
                    .fill(Color.black.opacity(0.18))

                    LinearGradient(
                        colors: [.white.opacity(0.3), .white.opacity(0), .black.opacity(0.16)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(width: outer * 2, height: outer * 2)
                    .mask {
                        DonutArc(
                            startAngle: .degrees(-90),
                            endAngle: .degrees(270),
                            innerRadius: inner,
                            outerRadius: outer
                        )
                    }

                    Circle()
                        .strokeBorder(
                            LinearGradient(
                                colors: [.white.opacity(0.5), .white.opacity(0.04)],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                        .frame(width: outer * 2, height: outer * 2)
                }
                .frame(width: size.width, height: size.height)
                .mask {
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(style: StrokeStyle(lineWidth: reach))
                        .frame(width: reach, height: reach)
                        .rotationEffect(.degrees(-90))
                }

                ForEach(segments) { segment in
                    if segment.slice.share >= Self.minLabelShare {
                        badge(for: segment, center: center, radius: outer + Self.badgeDistance)
                    }
                }
            }
            .frame(width: size.width, height: size.height)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                progress = 1
            }
        }
    }

    private func ring(_ segments: [Segment], inner: CGFloat, outer: CGFloat) -> some View {
        ZStack {
            ForEach(segments) { segment in
                DonutArc(
                    startAngle: .degrees(segment.start),
                    endAngle: .degrees(segment.end),
                    innerRadius: inner,
                    outerRadius: outer
                )
                .fill(segment.color)
            }
        }
    }

    private func badge(for segment: Segment, center: CGPoint, radius: CGFloat) -> some View {
        let isUpper = sin(segment.middle) < 0

        return Circle()
            .fill(segment.color.opacity(0.22))
            .frame(width: Self.badgeSize, height: Self.badgeSize)
            .overlay {
                segment.slice.category.categoryIcon.image
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(segment.color)
                    .frame(width: 20, height: 20)
            }
            .overlay {
                Text("\(segment.slice.percent)%")
                    .font(.appRegular(12))
                    .foregroundColor(segment.color)
                    .fixedSize()
                    .offset(y: (Self.badgeSize / 2 + 10) * (isUpper ? -1 : 1))
            }
            .position(
                x: center.x + CGFloat(cos(segment.middle)) * radius,
                y: center.y + CGFloat(sin(segment.middle)) * radius
            )
            .opacity(Double(progress))
    }
}

struct GlassBarChart: View {
    let points: [StatisticsChartPoint]
    let period: StatisticsPeriod
    var tint: Color = .appRed

    var body: some View {
        let stub = (points.map(\.value).max() ?? .zero) * 0.012

        Chart(points) { point in
            BarMark(
                x: .value("Date", point.start, unit: period.chartComponent),
                y: .value("Amount", max(point.value, stub)),
                width: .ratio(0.45)
            )
            .cornerRadius(5)
            .foregroundStyle(
                LinearGradient(
                    colors: [tint.mix(with: .white, by: 0.3), tint, tint.mix(with: .black, by: 0.12)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .shadow(color: tint.opacity(0.55), radius: 8)
        }
        .glassChartAxes(format: period.chartAxisFormat, centered: true)
    }
}

struct GlassLineChart: View {
    let points: [StatisticsChartPoint]
    let interval: DateInterval
    let period: StatisticsPeriod
    var tint: Color = .appRed

    var body: some View {
        let now = Date()
        let passed = points.filter { $0.start <= now }
        let visible = passed.isEmpty ? points : passed

        Chart {
            ForEach(visible) { point in
                AreaMark(
                    x: .value("Date", point.start),
                    y: .value("Total", point.totalValue)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(
                    LinearGradient(
                        colors: [tint.opacity(0.32), tint.opacity(0.02)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                LineMark(
                    x: .value("Date", point.start),
                    y: .value("Total", point.totalValue)
                )
                .interpolationMethod(.monotone)
                .foregroundStyle(tint)
                .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .shadow(color: tint.opacity(0.8), radius: 6)
            }

            if let last = visible.last {
                PointMark(
                    x: .value("Date", last.start),
                    y: .value("Total", last.totalValue)
                )
                .symbol {
                    Circle()
                        .fill(Color.appMain)
                        .overlay {
                            Circle()
                                .strokeBorder(tint, lineWidth: 2.5)
                        }
                        .frame(width: 11, height: 11)
                        .shadow(color: tint.opacity(0.8), radius: 5)
                }
            }
        }
        .chartXScale(domain: interval.start ... interval.end)
        .glassChartAxes(format: period.chartAxisFormat, centered: false)
    }
}

extension View {
    fileprivate func glassChartAxes(format: Date.FormatStyle, centered: Bool) -> some View {
        chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                AxisValueLabel(format: format, centered: centered)
                    .foregroundStyle(Color.appLabel)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { value in
                AxisGridLine()
                    .foregroundStyle(Color.appLabel.opacity(0.15))
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(amount.formatted(.number.notation(.compactName)))
                            .foregroundColor(.appLabel)
                    }
                }
            }
        }
        .chartLegend(.hidden)
    }
}

private func makePreviewSlices() -> [StatisticsSlice] {
    [
        StatisticsSlice(
            category: TransactionCategory(name: "Bills", categoryIcon: CategoryIcon(name: "banknote", iconColor: .green)),
            amount: 85000,
            share: 0.395
        ),
        StatisticsSlice(
            category: TransactionCategory(name: "Health", categoryIcon: CategoryIcon(name: "cross.case.fill", iconColor: .red)),
            amount: 65000,
            share: 0.3025
        ),
        StatisticsSlice(
            category: TransactionCategory(name: "Transport", categoryIcon: CategoryIcon(name: "tram.fill", iconColor: .yellow)),
            amount: 65000,
            share: 0.3025
        ),
    ]
}

private func makePreviewPoints() -> [StatisticsChartPoint] {
    let start = StatisticsPeriod.month.interval(containing: Date()).start
    let amounts = [0, 85000, 0, 65000, 65000, 0, 0, 120000, 30000, 0, 45000, 0, 210000, 15000]
    var total = 0
    return amounts.enumerated().map { index, amount in
        total += amount
        return StatisticsChartPoint(start: start.adding(index, .day), amount: amount, total: total)
    }
}

#Preview("Donut") {
    GlassDonutChart(slices: makePreviewSlices())
        .frame(height: 320)
        .padding(.horizontal, 16)
        .background(.appMain)
}

#Preview("Bars") {
    GlassBarChart(points: makePreviewPoints(), period: .month)
        .frame(height: 280)
        .padding(16)
        .background(.appMain)
}

#Preview("Line") {
    GlassLineChart(
        points: makePreviewPoints(),
        interval: StatisticsPeriod.month.interval(containing: Date()),
        period: .month
    )
    .frame(height: 280)
    .padding(16)
    .background(.appMain)
}
