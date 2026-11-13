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
    private static let transactionAddedSoundID: SystemSoundID = 1104
    private static let amountMissingSoundID: SystemSoundID = 1053

    static func transactionAdded() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(transactionAddedSoundID)
    }

    static func amountMissing() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        AudioServicesPlaySystemSound(amountMissingSoundID)
    }
}
