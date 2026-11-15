//
//  Settings.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 15.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct FeedbackSettings: Codable {
    var soundsEnabled: Bool = true
    var hapticEnabled: Bool = true
}

struct AppSettings: Codable {
    var theme: ThemePreset = .dark
    var statisticsChartStyle: StatisticsChartStyle = .pie
    var hideCategories: Bool = false
    var feedback = FeedbackSettings()
}
