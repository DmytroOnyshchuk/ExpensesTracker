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
    let onDismiss: () -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        HStack(spacing: 12) {
            Text(message)
                .font(.appRegular(16))
                .foregroundColor(LiquidGlass.isAvailable ? .appWhite : .appMain)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onUndo) {
                Text(L10n.undo)
                    .font(.appMedium(16))
                    .foregroundColor(.appPrimary)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .glassSurface(in: RoundedRectangle(cornerRadius: 18, style: .continuous), fallback: Color.appWhite)
        .contentShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .legacyShadow(color: .appOverlay.opacity(0.3), radius: 12, y: 4)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .offset(y: dragOffset)
        .gesture(dragGesture)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .global)
            .onChanged { value in
                dragOffset = value.translation.height > 0 ? value.translation.height : value.translation.height / 6
            }
            .onEnded { value in
                if value.translation.height > 30 || value.predictedEndTranslation.height > 120 {
                    onDismiss()
                } else {
                    withAnimation(.appSpring) { dragOffset = 0 }
                }
            }
    }
}

private struct UndoToastModifier: ViewModifier {
    let duration: Duration
    let isEnabled: Bool

    @State private var center = UndoToastCenter.shared

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if isEnabled, let item = center.item {
                    UndoToastView(message: item.message) {
                        FeedbackManager.shared.buttonTapped()
                        center.undo()
                    } onDismiss: {
                        center.dismiss(item.id)
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
            .animation(.appSpring, value: center.item?.id)
    }
}

extension View {
    func undoToast(duration: Duration = .seconds(4), isEnabled: Bool = true) -> some View {
        modifier(UndoToastModifier(duration: duration, isEnabled: isEnabled))
    }
}

extension ModelContext {
    @MainActor
    func deleteWithUndo(_ transaction: Transaction) {
        moveToTrash(transaction)

        UndoToastCenter.shared.show(L10n.transactionsListMovedToTrash) {
            self.restore(transaction)
        }
    }

    @MainActor
    func deleteWithUndo(_ account: Account) {
        moveToTrash(account)

        UndoToastCenter.shared.show(L10n.transactionsListMovedToTrash) {
            self.restore(account)
        }
    }

    @MainActor
    func deleteWithUndo(_ category: TransactionCategory) {
        moveToTrash(category)

        UndoToastCenter.shared.show(L10n.transactionsListMovedToTrash) {
            self.restore(category)
        }
    }

    @MainActor
    func deleteWithUndo(_ autoPayment: AutoPayment) {
        moveToTrash(autoPayment)

        UndoToastCenter.shared.show(L10n.transactionsListMovedToTrash) {
            self.restore(autoPayment)
        }
    }

    @MainActor
    func applyWithUndo(_ draft: TransactionDraft, to transaction: Transaction) {
        let previous = TransactionDraft(transaction)
        transaction.removeFromBalance()
        draft.apply(to: transaction)
        transaction.addToBalance()
        try? save()

        guard TransactionDraft(transaction) != previous else { return }

        UndoToastCenter.shared.show(L10n.transactionsListTransactionUpdated) {
            transaction.removeFromBalance()
            previous.apply(to: transaction)
            transaction.addToBalance()
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
