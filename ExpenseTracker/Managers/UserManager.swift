import Foundation
import SwiftData

enum UDKey: String, CaseIterable {
    case currentLanguage = "UDKey.currentLanguage"
    case lastApplicationEnvironment = "UDKey.lastApplicationEnvironment"
    case fcmToken = "UDKey.fcmToken"
    case apiToken = "UDKey.apiToken"
    case userId = "UDKey.userId"
    case balance = "UDKey.balance"
    case theme = "UDKey.theme"
    case statisticsChartStyle = "UDKey.statisticsChartStyle"
    case soundsEnabled = "UDKey.soundsEnabled"
    case hideCategories = "UDKey.hideCategories"
    case hapticEnabled = "UDKey.hapticEnabled"
}

final class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    @UserDefaultCodable(.currentLanguage, defaultValue: .English) var currentLanguage: Language!
    @UserDefaultCodable(.lastApplicationEnvironment, defaultValue: .develop) var lastApplicationEnvironment: AppEnvironment!
    @UserDefault(.fcmToken, defaultValue: nil) var fcmToken: String?
    @UserDefault(.apiToken, defaultValue: nil) var apiToken: String?
    @UserDefault(.userId, defaultValue: nil) var userId: String?
    @UserDefaultCodable(.theme, defaultValue: ThemePreset.dark) var theme: ThemePreset!
    @UserDefault(.soundsEnabled, defaultValue: true) var soundsEnabled: Bool!
    @UserDefault(.hapticEnabled, defaultValue: true) var hapticEnabled: Bool!
    @UserDefault(.hideCategories, defaultValue: false) var hideCategories: Bool!
    
}

extension UserManager {
    @MainActor
    func logout(context: ModelContext) throws {
        try clearDatabase(context)
        DataSeeder.seedDefaultCategories(in: context)

        let savedEnvironment: AppEnvironment = lastApplicationEnvironment

        let defaults = UserDefaults(suiteName: Constants.groupIdentifier) ?? .standard
        let dictionary = defaults.dictionaryRepresentation()
        for key in dictionary.keys {
            defaults.removeObject(forKey: key)
        }
        for key in UDKey.allCases {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
        }
        lastApplicationEnvironment = savedEnvironment
        _fcmToken.reset()
        _apiToken.reset()
        _userId.reset()
        _soundsEnabled.reset()
        _hapticEnabled.reset()
        _theme.reset()
        ThemeManager.shared.preset = theme

        Logger.default.logMessage("Logout end", category: "UserManager")
    }

    private func clearDatabase(_ context: ModelContext) throws {
        for transaction in try context.fetch(FetchDescriptor<Transaction>()) {
            context.delete(transaction)
        }
        for category in try context.fetch(FetchDescriptor<TransactionCategory>()) {
            context.delete(category)
        }
        try context.save()
    }

    func isLoggedIn() -> Bool {
        userId != nil
    }
}
