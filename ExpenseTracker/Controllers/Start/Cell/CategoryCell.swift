//
//  CategoryCell.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 30.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct CategoryCell: View {
    let category: TransactionCategory
    var action: () -> Bool

    @State private var pulseTrigger: Int = .zero

    var body: some View {
        if category.isDirectory {
            Button(action: select) {
                VStack(spacing: 8) {
                    ZStack {
                        Image(systemName: "folder.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.appYellow)
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
                        .keyframeAnimator(initialValue: 1.0, trigger: pulseTrigger) { content, scale in
                            content.scaleEffect(scale)
                        } keyframes: { _ in
                            CubicKeyframe(2.5, duration: 0.3)
                            CubicKeyframe(1.0, duration: 0.5)
                        }

                    Spacer(minLength: 8)

                    Text(category.name.localized)
                        .font(.appRegular(12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.appWhite)
                        .lineLimit(1)
                        .keyframeAnimator(initialValue: 1.0, trigger: pulseTrigger) { content, opacity in
                            content.opacity(opacity)
                        } keyframes: { _ in
                            CubicKeyframe(0.0, duration: 0.15)
                            LinearKeyframe(0.0, duration: 0.35)
                            CubicKeyframe(1.0, duration: 0.3)
                        }
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
