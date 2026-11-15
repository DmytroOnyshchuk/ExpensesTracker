import Foundation
import SwiftData

enum UDKey: String {
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
    @UserDefaultCodable(.balance, defaultValue: nil, enableCaching: false) var balance: Balance?
    @UserDefaultCodable(.statisticsChartStyle, defaultValue: .pie, enableCaching: false) var statisticsChartStyle: StatisticsChartStyle!
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
        _currentLanguage.reset()
        _lastApplicationEnvironment.reset()
        _fcmToken.reset()
        _apiToken.reset()
        _userId.reset()
        _theme.reset()
        _soundsEnabled.reset()
        _hapticEnabled.reset()
        _hideCategories.reset()
        _balance.reset()
        _statisticsChartStyle.reset()
        lastApplicationEnvironment = savedEnvironment
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
