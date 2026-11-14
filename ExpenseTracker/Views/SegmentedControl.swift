//
//  SegmentedControl.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct SegmentedControl<Item: Hashable>: View {
    let items: [Item]
    @Binding var selection: Item
    let title: (Item) -> String

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                Button {
                    selection = item
                } label: {
                    Text(title(item))
                        .font(.appLight(18))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                        .foregroundColor(item == selection ? .appWhite : .appPrimary)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background {
                            if item == selection {
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
        .glassSurface(in: RoundedRectangle(cornerRadius: 10), fallback: .clear)
        .overlay {
            if !LiquidGlass.isAvailable {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.appLabel.opacity(0.4), lineWidth: 1.5)
            }
        }
    }
}

#Preview {
    @Previewable @State var selection = "Month"

    SegmentedControl(items: ["Day", "Month", "Year"], selection: $selection) { $0 }
        .padding(.horizontal, 64)
        .padding(.vertical, 16)
        .background(.appMain)
}
