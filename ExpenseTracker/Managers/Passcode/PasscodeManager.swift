//
//  PasscodeManager.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 17.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import LocalAuthentication
import Observation
import SwiftUI
import UIKit

@Observable
final class PasscodeManager {
    static let shared = PasscodeManager()
    static let passcodeLength = 4

    private(set) var isPasscodeEnabled: Bool
    private(set) var isLocked: Bool
    private(set) var biometryType: LABiometryType = .none
    private(set) var isBiometryAvailable = false

    @ObservationIgnored private var lockWindow: UIWindow?
    @ObservationIgnored private var shouldPromptBiometrics = false
    @ObservationIgnored private var isAuthenticating = false
    @ObservationIgnored private var observers = [NSObjectProtocol]()

    var canUnlockWithBiometrics: Bool {
        isBiometryAvailable && UserManager.shared.appSettings.security.biometricsEnabled
    }

    private init() {
        var isEnabled = UserManager.shared.appSettings.security.passcodeEnabled
        if isEnabled, PasscodeStorage.state == .missing {
            isEnabled = false
            UserManager.shared.appSettings.security.passcodeEnabled = false
        }
        self.isPasscodeEnabled = isEnabled
        self.isLocked = isEnabled
        self.shouldPromptBiometrics = isEnabled
        refreshBiometry()
        observeApplication()
    }

    func start() {
        guard isLocked else { return }
        showLockWindow()
        promptBiometricsIfNeeded()
    }
}

extension PasscodeManager {
    func verify(_ passcode: String) -> Bool {
        PasscodeStorage.verify(passcode)
    }

    @discardableResult
    func setPasscode(_ passcode: String) -> Bool {
        guard PasscodeStorage.save(passcode) else { return false }
        UserManager.shared.appSettings.security.passcodeEnabled = true
        isPasscodeEnabled = true
        return true
    }

    func disablePasscode() {
        PasscodeStorage.delete()
        UserManager.shared.appSettings.security.passcodeEnabled = false
        isPasscodeEnabled = false
        unlock()
    }

    func reset() {
        PasscodeStorage.delete()
        isPasscodeEnabled = false
        unlock()
    }

    func unlock(with passcode: String) -> Bool {
        guard verify(passcode) else { return false }
        unlock()
        return true
    }

    func unlockWithBiometrics() {
        guard isLocked else { return }
        authenticateWithBiometrics { [weak self] in
            self?.unlock()
        }
    }

    func authenticateWithBiometrics(reason: String = L10n.passcodeBiometricsReason, onSuccess: @escaping () -> Void) {
        guard canUnlockWithBiometrics, !isAuthenticating else { return }
        isAuthenticating = true

        let context = LAContext()
        context.localizedFallbackTitle = ""
        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, _ in
            DispatchQueue.main.async {
                self?.isAuthenticating = false
                if success { onSuccess() }
            }
        }
    }
}

extension PasscodeManager {
    private func observeApplication() {
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.lock()
        })
        observers.append(center.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self else { return }
            refreshBiometry()
            guard isLocked else { return }
            showLockWindow()
            promptBiometricsIfNeeded()
        })
    }

    private func refreshBiometry() {
        let context = LAContext()
        isBiometryAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        biometryType = context.biometryType
    }

    private func lock() {
        guard isPasscodeEnabled, !isLocked else { return }
        isLocked = true
        shouldPromptBiometrics = true
        showLockWindow()
    }

    private func unlock() {
        isLocked = false
        shouldPromptBiometrics = false
        hideLockWindow()
    }

    private func promptBiometricsIfNeeded() {
        guard shouldPromptBiometrics, UIApplication.shared.applicationState == .active else { return }
        shouldPromptBiometrics = false
        unlockWithBiometrics()
    }

    private func showLockWindow() {
        guard lockWindow == nil,
              let scene = UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first
        else { return }

        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

        let window = UIWindow(windowScene: scene)
        window.windowLevel = .alert + 1
        window.rootViewController = UIHostingController(rootView: PasscodeLockView())
        window.isHidden = false
        lockWindow = window
    }

    private func hideLockWindow() {
        guard let window = lockWindow else { return }
        lockWindow = nil
        UIView.animate(withDuration: 0.25) {
            window.alpha = 0
        } completion: { _ in
            window.isHidden = true
        }
    }
}

extension LABiometryType {
    var title: String {
        switch self {
        case .faceID: "Face ID"
        case .touchID: "Touch ID"
        case .opticID: "Optic ID"
        default: "Face ID / Touch ID"
        }
    }

    var systemImage: String {
        switch self {
        case .touchID: "touchid"
        case .opticID: "opticid"
        default: "faceid"
        }
    }
}
