//
//  CommentInputView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 12.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct CommentInputView: View {
    @Binding var comment: String
    @Binding var isPresented: Bool

    @State private var draft = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture(perform: close)

            VStack(spacing: 14) {
                header
                HStack(alignment: .bottom, spacing: 10) {
                    field
                    saveButton
                }
            }
            .padding(16)
            .background(.appSecond)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: .black.opacity(0.3), radius: 24, y: 8)
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
        }
        .onAppear {
            draft = comment
            isFocused = true
        }
    }

    private var header: some View {
        HStack(spacing: 4) {
            Text(L10n.transactionEditAddComment)
                .font(.appMedium(16))
                .foregroundColor(.appLabel)
                .padding(.leading, 4)

            Spacer()

            if !draft.isEmpty {
                Button(action: { tap(clear) }) {
                    Text(L10n.clear)
                        .font(.appRegular(15))
                        .foregroundColor(.appBlue)
                        .padding(.horizontal, 10)
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
        .animation(.easeInOut(duration: 0.15), value: draft.isEmpty)
    }

    private var field: some View {
        TextField(
            "",
            text: $draft,
            prompt: Text(L10n.transactionEditAddComment).foregroundColor(.appLabel.opacity(0.6)),
            axis: .vertical
        )
        .lineLimit(3 ... 6)
        .focused($isFocused)
        .font(.appLight(18))
        .foregroundColor(.appWhite)
        .tint(.appBlue)
        .padding(.horizontal, 16)
        .padding(.vertical, 11)
        .frame(minHeight: 44)
        .background(.appMain)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var saveButton: some View {
        Button(action: { tap(save) }) {
            Image(systemName: "checkmark")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.appWhite)
                .frame(width: 44, height: 44)
                .background(.appBlue)
                .clipShape(Circle())
        }
    }

    private func tap(_ action: () -> Void) {
        FeedbackManager.buttonTapped()
        action()
    }

    private func clear() {
        draft = ""
    }

    private func save() {
        comment = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        close()
    }

    private func close() {
        isFocused = false
        isPresented = false
    }
}

#Preview {
    @Previewable @State var comment = "Lunch with colleagues"
    @Previewable @State var isPresented = true

    CommentInputView(comment: $comment, isPresented: $isPresented)
        .background(.appMain)
}
