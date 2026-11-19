//
//  NoteInputView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct NoteInputView: View {
    @Binding var note: String
    @Binding var isPresented: Bool

    @State private var draft = String()
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.appOverlay.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: close)

            VStack(spacing: 12) {
                header
                HStack(alignment: .bottom, spacing: 8) {
                    field
                    saveButton
                }
            }
            .padding(16)
            .glassSurface(in: RoundedRectangle(cornerRadius: 28, style: .continuous), fallback: .appSecond)
            .contentShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .onTapGesture {}
            .legacyShadow(color: .appOverlay.opacity(0.3), radius: 12, y: 4)
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .onAppear {
            draft = note
            isFocused = true
        }
    }

    private var header: some View {
        HStack(spacing: 4) {
            Text(L10n.transactionEditAddNote)
                .font(.appMedium(16))
                .foregroundColor(.appLabel)
                .padding(.leading, 4)

            Spacer()

            if !draft.isEmpty {
                Button(action: { tap(clear) }) {
                    Text(L10n.clear)
                        .font(.appRegular(15))
                        .foregroundColor(.appPrimary)
                        .padding(.horizontal, 12)
                        .frame(minHeight: 32)
                        .contentShape(Rectangle())
                }
                .transition(.opacity)
            }

            Button(action: close) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.appLabel)
                    .frame(width: 32, height: 32)
                    .background(.appLabel.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .animation(.appFast, value: draft.isEmpty)
    }

    private var field: some View {
        TextField(
            "",
            text: $draft,
            prompt: Text(L10n.transactionEditAddNote).foregroundColor(.appLabel.opacity(0.6)),
            axis: .vertical
        )
        .lineLimit(3 ... 6)
        .focused($isFocused)
        .font(.appLight(18))
        .foregroundColor(.appWhite)
        .tint(.appPrimary)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 44)
        .background(.appMain.opacity(LiquidGlass.isAvailable ? 0.5 : 1), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var saveButton: some View {
        Button(action: { tap(save) }) {
            Image(systemName: "checkmark")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.appMain)
                .frame(width: 44, height: 44)
                .background(.appPrimary)
                .clipShape(Circle())
        }
    }

    private func tap(_ action: () -> Void) {
        FeedbackManager.shared.buttonTapped()
        action()
    }

    private func clear() {
        draft = String()
    }

    private func save() {
        note = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        close()
    }

    private func close() {
        isFocused = false
        isPresented = false
    }
}

#Preview {
    @Previewable @State var note = "Lunch with colleagues"
    @Previewable @State var isPresented = true

    NoteInputView(note: $note, isPresented: $isPresented)
        .background(.appMain)
}
