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
        ZStack(alignment: .top) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: close)

            VStack(spacing: 0) {
                TextEditor(text: $draft)
                    .focused($isFocused)
                    .font(.appLight(18))
                    .foregroundColor(.appWhite)
                    .scrollContentBackground(.hidden)
                    .frame(height: 150)
                    .padding(.horizontal, 8)
                    .padding(.top, 8)

                HStack {
                    actionButton(L10n.clear) {
                        draft = ""
                    }
                    Spacer()
                    actionButton(L10n.cancel, action: close)
                    Spacer()
                    actionButton(L10n.ok, action: save)
                }
                .padding(.horizontal, 4)
            }
            .background(.appSecond)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .padding(.horizontal, 20)
            .padding(.top, 96)
        }
        .onAppear {
            draft = comment
            isFocused = true
        }
    }

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.appLight(18))
                .foregroundColor(.appBlue)
                .padding(.horizontal, 12)
                .frame(minWidth: 44, minHeight: 48)
                .contentShape(Rectangle())
        }
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
