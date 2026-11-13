//
//  CategoryCell.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 30.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

private struct Pulse {
    var scale = 1.0
    var opacity = 0.0
}

struct CategoryCell: View {
    let category: TransactionCategory
    var action: () -> Bool

    @State private var pulseTrigger = 0

    var body: some View {
        if category.isDirectory {
            Button(action: select) {
                VStack(spacing: 8) {
                    ZStack {
                        Image(systemName: "folder.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.yellow)
                            .frame(height: 60)

                        category.categoryIcon.image
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.appMain)
                            .frame(width: 24, height: 24)
                            .offset(y: 8)
                    }

                    Text(category.name.localized)
                        .font(.caption)
                        .foregroundColor(.appWhite)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .buttonStyle(.plain)
        } else {
            Button(action: select) {
                VStack {
                    icon
                        .overlay {
                            icon
                                .keyframeAnimator(initialValue: Pulse(), trigger: pulseTrigger) { content, pulse in
                                    content
                                        .scaleEffect(pulse.scale)
                                        .opacity(pulse.opacity)
                                } keyframes: { _ in
                                    KeyframeTrack(\.scale) {
                                        MoveKeyframe(1.0)
                                        LinearKeyframe(2.5, duration: 0.6, timingCurve: .easeOut)
                                    }
                                    KeyframeTrack(\.opacity) {
                                        MoveKeyframe(1.0)
                                        LinearKeyframe(0.0, duration: 0.6, timingCurve: .easeIn)
                                    }
                                }
                                .allowsHitTesting(false)
                        }

                    Spacer(minLength: 8)

                    Text(category.name.localized)
                        .font(.appRegular(12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.appWhite)
                        .lineLimit(1)
                }
                .frame(height: 80)
            }
            .buttonStyle(.plain)
        }
    }

    private var icon: some View {
        category.categoryIcon.image
            .resizable()
            .scaledToFit()
            .foregroundColor(category.categoryIcon.color)
            .frame(width: 48, height: 56)
    }

    private func select() {
        if action() {
            pulseTrigger += 1
        }
    }
}

#Preview("Category") {
    CategoryCell(
        category: TransactionCategory(name: "Groceries", categoryIcon: CategoryIcon(name: "cart", iconColor: .green)),
        action: { true }
    )
    .frame(width: 80, height: 90)
    .padding()
    .background(.appMain)
}

#Preview("Category folder") {
    CategoryCell(
        category: TransactionCategory(name: "Home", categoryIcon: CategoryIcon(name: "house", iconColor: .yellow), isDirectory: true),
        action: { true }
    )
    .frame(width: 80, height: 90)
    .padding()
    .background(.appMain)
}
