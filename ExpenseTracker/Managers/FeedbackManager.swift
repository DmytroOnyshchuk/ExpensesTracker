//
//  FeedbackManager.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 13.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import AudioToolbox
import UIKit

enum FeedbackSound {
    case keyTap
    case keyDelete
    case transactionAdded
    case amountMissing

    var fallbackSoundID: SystemSoundID {
        switch self {
        case .keyTap: 1104
        case .keyDelete: 1155
        case .transactionAdded: 1104
        case .amountMissing: 1053
        }
    }

    var systemFilename: String? {
        switch self {
        case .transactionAdded: "payment_success"
        case .keyTap, .keyDelete, .amountMissing: nil
        }
    }
}

final class FeedbackManager {
    static let shared = FeedbackManager()

    @Inject private var userManager: UserManager

    private var soundIDs = [FeedbackSound: SystemSoundID]()

    private init() {}
}

extension FeedbackManager {
    var soundIsEnable: Bool {
        userManager.soundsEnabled ?? true
    }

    func enableSound(_ enable: Bool) {
        userManager.soundsEnabled = enable
    }

    // MARK: -

    func keyTapped(_ key: AmountInput.Key) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        playSound(key == .backspace ? .keyDelete : .keyTap)
    }

    func buttonTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    func selectionChanged() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    func transactionAdded() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        playSound(.transactionAdded)
    }

    func amountMissing() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
        playSound(.amountMissing)
    }
}

extension FeedbackManager {
    private func playSound(_ sound: FeedbackSound) {
        guard soundIsEnable else { return }
        AudioServicesPlaySystemSound(soundID(for: sound))
    }

    private func soundID(for sound: FeedbackSound) -> SystemSoundID {
        if let soundID = soundIDs[sound] { return soundID }

        var soundID = sound.fallbackSoundID
        if let filename = sound.systemFilename {
            let url = URL(fileURLWithPath: "/System/Library/Audio/UISounds/\(filename).caf")
            var createdSoundID: SystemSoundID = .zero
            if AudioServicesCreateSystemSoundID(url as CFURL, &createdSoundID) == kAudioServicesNoError {
                soundID = createdSoundID
            }
        }

        soundIDs[sound] = soundID
        return soundID
    }
}
