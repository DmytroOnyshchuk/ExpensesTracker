//
//  UndoToastView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftData
import SwiftUI

@MainActor
@Observable
final class UndoToastCenter {
    struct Item: Identifiable {
        let id = UUID()
        let message: String
        let undo: () -> Void
    }

    static let shared = UndoToastCenter()

    private(set) var item: Item?

    func show(_ message: String, undo: @escaping () -> Void) {
        item = Item(message: message, undo: undo)
    }

    func undo() {
        let undo = item?.undo
        item = nil
        undo?()
    }

    func dismiss(_ id: UUID) {
        if item?.id == id {
            item = nil
        }
    }
}

struct UndoToastView: View {
    let message: String
    let onUndo: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(message)
                .font(.appRegular(16))
                .foregroundColor(.appMain)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onUndo) {
                Text(L10n.undo)
                    .font(.appMedium(16))
                    .foregroundColor(.appBlue)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
        .background(.appWhite)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .appBlack.opacity(0.3), radius: 12, y: 4)
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
    }
}

private struct UndoToastModifier: ViewModifier {
    let duration: Duration

    @State private var center = UndoToastCenter.shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let item = center.item {
                    UndoToastView(message: item.message) {
                        FeedbackManager.buttonTapped()
                        center.undo()
                    }
                    .id(item.id)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .task(id: item.id) {
                        try? await Task.sleep(for: duration)
                        guard !Task.isCancelled else { return }
                        center.dismiss(item.id)
                    }
                }
            }
            .animation(.spring(duration: 0.3), value: center.item?.id)
    }
}

extension View {
    func undoToast(duration: Duration = .seconds(4)) -> some View {
        modifier(UndoToastModifier(duration: duration))
    }
}

extension ModelContext {
    @MainActor
    func deleteWithUndo(_ transaction: Transaction) {
        let id = transaction.id
        let amount = transaction.amount
        let category = transaction.category
        let date = transaction.date
        let comment = transaction.comment

        delete(transaction)
        try? save()

        UndoToastCenter.shared.show(L10n.transactionsListTransactionDeleted) {
            let restored = Transaction(amount: amount, category: category, date: date, note: comment)
            restored.id = id
            self.insert(restored)
            try? self.save()
        }
    }
}

#Preview {
    Color.appMain
        .ignoresSafeArea()
        .undoToast(duration: .seconds(60))
        .onAppear {
            UndoToastCenter.shared.show("Transaction deleted") {}
        }
}
