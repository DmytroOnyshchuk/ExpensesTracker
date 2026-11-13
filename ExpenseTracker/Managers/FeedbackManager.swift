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

    static func transactionAdded() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        AudioServicesPlaySystemSound(transactionAddedSoundID)
    }
}
