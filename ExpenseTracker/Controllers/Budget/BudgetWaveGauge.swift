//
//  BudgetWaveGauge.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 17.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct BudgetWaveShape: Shape {
    var level: Double
    var phase: Double
    let amplitude: CGFloat
    let waves: Double

    var animatableData: Double {
        get { level }
        set { level = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let damping = min(1, level * 6, (1 - level) * 6)
        let height = amplitude * max(damping, .zero)
        let baseline = rect.maxY - rect.height * level

        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))

        for step in 0 ... Int(rect.width / 2) {
            let x = min(rect.minX + CGFloat(step) * 2, rect.maxX)
            let relative = (x - rect.minX) / max(rect.width, 1)
            path.addLine(to: CGPoint(x: x, y: baseline + sin(relative * waves * 2 * .pi + phase) * height))
        }

        path.addLine(to: CGPoint(x: rect.maxX, y: baseline + sin(waves * 2 * .pi + phase) * height))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct BudgetWaveGauge: View {
    let spent: Int
    let limit: Int
    var size: CGFloat = 190

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isFilled = false

    private var remaining: Int { limit - spent }
    private var isExceeded: Bool { remaining < .zero }
    private var color: Color { isExceeded ? .appRed : .appPrimary }

    private var fraction: Double {
        guard limit > .zero else { return .zero }
        return min(max(remaining.double / limit.double, .zero), 1)
    }

    var body: some View {
        let level = isFilled ? fraction : .zero

        TimelineView(.animation(paused: reduceMotion)) { context in
            let time = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 3600)

            ZStack {
                Circle()
                    .fill(RadialGradient(colors: [color.opacity(0.5), color.opacity(0.28), color.opacity(0.1)], center: UnitPoint(x: 0.5, y: 0.4), startRadius: .zero, endRadius: size * 0.6))

                BudgetWaveShape(level: level, phase: time * 1.1, amplitude: size * 0.028, waves: 1.3)
                    .fill(color.opacity(0.4))

                BudgetWaveShape(level: level, phase: 2 - time * 1.7, amplitude: size * 0.036, waves: 0.9)
                    .fill(LinearGradient(colors: [color, color.opacity(0.7)], startPoint: .top, endPoint: .bottom))
            }
            .clipShape(Circle())
        }
        .background {
            Circle()
                .stroke(color.opacity(0.55), lineWidth: size * 0.05)
                .blur(radius: size * 0.06)
        }
        .overlay {
            Circle()
                .strokeBorder(isExceeded ? Color.appRed.opacity(0.6) : Color.appWhite.opacity(0.2), lineWidth: 1)
        }
        .overlay {
            VStack(spacing: 2) {
                Text("\(Int((fraction * 100).rounded()))%")
                    .font(.appRegular(34))
                    .foregroundColor(.appWhite)
                    .contentTransition(.numericText())

                Text(isExceeded ? L10n.budgetExceeded((-remaining).getAmount()) : L10n.budgetLeft(remaining.getAmount()))
                    .font(.appLight(14))
                    .foregroundColor(isExceeded ? .appRed : .appWhite)
                    .contentTransition(.numericText())
            }
            .lineLimit(1)
            .minimumScaleFactor(0.6)
            .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
            .padding(.horizontal, size * 0.12)
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.8), value: level)
        .onAppear {
            isFilled = true
        }
    }
}

#Preview("Budget wave gauge") {
    VStack(spacing: 24) {
        BudgetWaveGauge(spent: 825800, limit: 1500000)
        BudgetWaveGauge(spent: 120000, limit: 1500000, size: 140)
        BudgetWaveGauge(spent: 71800, limit: 12500, size: 140)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.appMain)
}
