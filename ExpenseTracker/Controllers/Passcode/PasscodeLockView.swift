//
//  PasscodeLockView.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 17.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct PasscodeLockView: View {
    @State private var code = ""
    @State private var errorMessage: String?
    @State private var shakeTrigger: Int = .zero

    private let passcodeManager = PasscodeManager.shared

    var body: some View {
        PasscodeEntryView(
            title: L10n.passcodeEnter,
            errorMessage: errorMessage,
            code: $code,
            shakeTrigger: shakeTrigger,
            biometricsImage: passcodeManager.canUnlockWithBiometrics ? passcodeManager.biometryType.systemImage : nil,
            onBiometrics: passcodeManager.unlockWithBiometrics,
            onComplete: submit
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .appBackground()
        .modifier(SystemColorSchemeObserver())
        .preferredColorScheme(ThemeManager.shared.preferredColorScheme)
    }

    private func submit(_ passcode: String) {
        Task {
            try? await Task.sleep(for: .milliseconds(150))
            if passcodeManager.unlock(with: passcode) {
                errorMessage = nil
            } else {
                FeedbackManager.shared.passcodeRejected()
                errorMessage = L10n.passcodeWrong
                shakeTrigger += 1
            }
            code = ""
        }
    }
}

#Preview {
    PasscodeLockView()
}
