//
//  PasscodeEntryView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 17.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct PasscodeEntryView: View {
    enum Key: Hashable {
        case digit(Int)
        case biometrics
        case backspace
    }

    let title: String
    var errorMessage: String?
    @Binding var code: String
    var shakeTrigger: Int = .zero
    var biometricsImage: String?
    var onBiometrics: () -> Void = {}
    let onComplete: (String) -> Void

    private let buttons: [[Key]] = [
        [.digit(1), .digit(2), .digit(3)],
        [.digit(4), .digit(5), .digit(6)],
        [.digit(7), .digit(8), .digit(9)],
        [.biometrics, .digit(0), .backspace],
    ]

    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                Text(title)
                    .font(.appLight(22))
                    .foregroundColor(.appWhite)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)

                HStack(spacing: 16) {
                    ForEach(0 ..< PasscodeManager.passcodeLength, id: \.self) { index in
                        Circle()
                            .fill(index < code.count ? Color.appPrimary : Color.clear)
                            .overlay {
                                Circle().stroke(index < code.count ? Color.appPrimary : Color.appLabel, lineWidth: 1.5)
                            }
                            .frame(width: 16, height: 16)
                    }
                }
                .animation(.appFast, value: code)
                .keyframeAnimator(initialValue: CGFloat.zero, trigger: shakeTrigger) { content, offset in
                    content.offset(x: offset)
                } keyframes: { _ in
                    LinearKeyframe(-12, duration: 0.06)
                    LinearKeyframe(12, duration: 0.08)
                    LinearKeyframe(-8, duration: 0.08)
                    LinearKeyframe(8, duration: 0.08)
                    LinearKeyframe(0, duration: 0.06)
                }

                Text(errorMessage ?? " ")
                    .font(.appLight(14))
                    .foregroundColor(.appRed)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .padding(.horizontal, 16)

            GlassContainer(spacing: 0) {
                VStack(spacing: 12) {
                    ForEach(buttons, id: \.self) { row in
                        HStack(spacing: 12) {
                            ForEach(row, id: \.self) { key in
                                button(for: key)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func button(for key: Key) -> some View {
        if key == .biometrics, biometricsImage == nil {
            Color.clear
                .frame(width: 75, height: 75)
        } else {
            Button(action: { tap(key) }) {
                label(for: key)
                    .frame(width: 75, height: 75)
                    .foregroundColor(
                        ThemeManager.shared.theme.colorScheme == .light
                            ? .appWhite.mix(with: .appMain, by: 0.12)
                            : .appWhite
                    )
                    .glassSurface(in: Circle(), isInteractive: true, fallback: .appLabel.opacity(0.1))
            }
        }
    }

    @ViewBuilder
    private func label(for key: Key) -> some View {
        switch key {
        case let .digit(digit):
            Text(String(digit))
                .font(.appLight(42))
        case .biometrics:
            Image(systemName: biometricsImage ?? "faceid")
                .font(.system(size: 26, weight: .regular))
        case .backspace:
            Image(systemName: "delete.backward.fill")
                .font(.system(size: 20, weight: .medium))
        }
    }

    private func tap(_ key: Key) {
        switch key {
        case let .digit(digit):
            guard code.count < PasscodeManager.passcodeLength else { return }
            FeedbackManager.shared.keyTapped(.digit(digit))
            code.append(String(digit))
            if code.count == PasscodeManager.passcodeLength {
                onComplete(code)
            }
        case .backspace:
            guard !code.isEmpty, code.count < PasscodeManager.passcodeLength else { return }
            FeedbackManager.shared.keyTapped(.backspace)
            code.removeLast()
        case .biometrics:
            FeedbackManager.shared.buttonTapped()
            onBiometrics()
        }
    }
}

#Preview {
    @Previewable @State var code = "12"

    PasscodeEntryView(title: "Enter passcode", errorMessage: "Wrong passcode", code: $code, biometricsImage: "faceid") { _ in
        code = ""
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .appBackground()
}
