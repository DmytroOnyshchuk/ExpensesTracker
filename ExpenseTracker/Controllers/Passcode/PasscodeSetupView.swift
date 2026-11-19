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
    case verify

    var id: Self { self }
}

struct PasscodeSetupView: View {
    enum Step: Equatable {
        case verify
        case enter
        case confirm(String)
    }

    let flow: PasscodeFlow
    let onVerified: () -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var step: Step
    @State private var code = ""
    @State private var errorMessage: String?
    @State private var shakeTrigger: Int = .zero

    private let passcodeManager = PasscodeManager.shared

    init(flow: PasscodeFlow, onVerified: @escaping () -> Void = {}) {
        self.flow = flow
        self.onVerified = onVerified
        _step = State(initialValue: flow == .create ? .enter : .verify)
    }

    var body: some View {
        NavigationStack {
            PasscodeEntryView(
                title: title,
                errorMessage: errorMessage,
                code: $code,
                shakeTrigger: shakeTrigger,
                biometricsImage: canUseBiometrics ? passcodeManager.biometryType.systemImage : nil,
                onBiometrics: authenticateWithBiometrics,
                onComplete: submit
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackground()
            .onAppear(perform: authenticateWithBiometrics)
            .navigationTitle(L10n.settingsPasscode)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.cancel) { dismiss() }
                        .foregroundColor(.appWhite)
                }
            }
        }
    }

    private var canUseBiometrics: Bool {
        (flow == .verify || flow == .disable) && passcodeManager.canUnlockWithBiometrics
    }

    private func authenticateWithBiometrics() {
        guard canUseBiometrics else { return }
        passcodeManager.authenticateWithBiometrics(reason: flow == .verify ? L10n.backupsResetAction : L10n.passcodeBiometricsReason) {
            if flow == .disable {
                passcodeManager.disablePasscode()
            } else {
                onVerified()
            }
            dismiss()
        }
    }

    private var title: String {
        switch step {
        case .verify: flow == .verify ? L10n.passcodeEnter : L10n.passcodeEnterCurrent
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
            switch flow {
            case .disable:
                passcodeManager.disablePasscode()
                dismiss()
            case .verify:
                onVerified()
                dismiss()
            case .create, .change:
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
