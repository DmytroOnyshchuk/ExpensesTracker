//
//  FeedbackManager.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import AudioToolbox
import UIKit

enum FeedbackManager {
    private static let fallbackTransactionAddedSoundID: SystemSoundID = 1104
    private static let transactionAddedSoundID: SystemSoundID = {
        let url = URL(fileURLWithPath: "/System/Library/Audio/UISounds/payment_success.caf")
        var soundID: SystemSoundID = 0
        let status = AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        return status == kAudioServicesNoError ? soundID : fallbackTransactionAddedSoundID
    }()

    private static let amountMissingSoundID: SystemSoundID = 1053
    private static let keyTapSoundID: SystemSoundID = 1104
    private static let keyDeleteSoundID: SystemSoundID = 1155

    static func keyTapped(_ key: AmountInput.Key) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        AudioServicesPlaySystemSound(key == .backspace ? keyDeleteSoundID : keyTapSoundID)
    }

    static func buttonTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func transactionAdded() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(transactionAddedSoundID)
    }

    static func amountMissing() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        AudioServicesPlaySystemSound(amountMissingSoundID)
    }
}
