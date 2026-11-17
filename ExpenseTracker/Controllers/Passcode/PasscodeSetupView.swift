//
//  PasscodeSetupView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 17.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

enum PasscodeFlow: Identifiable {
    case create
    case change
    case disable

    var id: Self { self }
}

struct PasscodeSetupView: View {
    enum Step: Equatable {
        case verify
        case enter
        case confirm(String)
    }

    let flow: PasscodeFlow

    @Environment(\.dismiss) private var dismiss

    @State private var step: Step
    @State private var code = ""
    @State private var errorMessage: String?
    @State private var shakeTrigger: Int = .zero

    private let passcodeManager = PasscodeManager.shared

    init(flow: PasscodeFlow) {
        self.flow = flow
        _step = State(initialValue: flow == .create ? .enter : .verify)
    }

    var body: some View {
        NavigationStack {
            PasscodeEntryView(
                title: title,
                errorMessage: errorMessage,
                code: $code,
                shakeTrigger: shakeTrigger,
                onComplete: submit
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackground()
            .navigationTitle(L10n.settingsPasscode)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.cancel) { dismiss() }
                        .tint(.appPrimary)
                }
            }
        }
    }

    private var title: String {
        switch step {
        case .verify: L10n.passcodeEnterCurrent
        case .enter: L10n.passcodeEnterNew
        case .confirm: L10n.passcodeRepeat
        }
    }

    private func submit(_ passcode: String) {
        Task {
            try? await Task.sleep(for: .milliseconds(150))
            handle(passcode)
            code = ""
        }
    }

    private func handle(_ passcode: String) {
        switch step {
        case .verify:
            guard passcodeManager.verify(passcode) else {
                fail(L10n.passcodeWrong)
                return
            }
            errorMessage = nil
            if flow == .disable {
                passcodeManager.disablePasscode()
                dismiss()
            } else {
                step = .enter
            }
        case .enter:
            errorMessage = nil
            step = .confirm(passcode)
        case let .confirm(first):
            guard passcode == first else {
                step = .enter
                fail(L10n.passcodeMismatch)
                return
            }
            guard passcodeManager.setPasscode(passcode) else {
                step = .enter
                fail(L10n.somethingWentWrong)
                return
            }
            dismiss()
        }
    }

    private func fail(_ message: String) {
        FeedbackManager.shared.passcodeRejected()
        errorMessage = message
        shakeTrigger += 1
    }
}

#Preview {
    PasscodeSetupView(flow: .create)
}
