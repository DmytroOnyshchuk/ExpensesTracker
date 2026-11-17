import Foundation
import SwiftData

enum UDKey: String {
    case currentLanguage = "UDKey.currentLanguage"
    case lastApplicationEnvironment = "UDKey.lastApplicationEnvironment"
    case fcmToken = "UDKey.fcmToken"
    case apiToken = "UDKey.apiToken"
    case userId = "UDKey.userId"
    case budget = "UDKey.budget"
    case appSettings = "UDKey.appSettings"
    case selectedAccount = "UDKey.selectedAccount"
}

final class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    @UserDefaultCodable(.currentLanguage, defaultValue: .English) var currentLanguage: Language!
    @UserDefaultCodable(.lastApplicationEnvironment, defaultValue: .develop) var lastApplicationEnvironment: AppEnvironment!
    @UserDefault(.fcmToken, defaultValue: nil) var fcmToken: String?
    @UserDefault(.apiToken, defaultValue: nil) var apiToken: String?
    @UserDefault(.userId, defaultValue: nil) var userId: String?
    @UserDefaultCodable(.budget, defaultValue: nil, enableCaching: false) var budget: Budget?
    @UserDefaultCodable(.appSettings, defaultValue: AppSettings(), enableCaching: false) var appSettings: AppSettings!
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
        _budget.reset()
        _appSettings.reset()
        lastApplicationEnvironment = savedEnvironment
        ThemeManager.shared.preset = appSettings.theme

        Logger.default.logMessage("Logout end", category: "UserManager")
    }

    private func clearDatabase(_ context: ModelContext) throws {
        for transaction in try context.fetch(FetchDescriptor<Transaction>()) {
            context.delete(transaction)
        }
        for category in try context.fetch(FetchDescriptor<TransactionCategory>()) {
            context.delete(category)
        }
        for account in try context.fetch(FetchDescriptor<Account>()) {
            context.delete(account)
        }
        try context.save()
    }

    func isLoggedIn() -> Bool {
        userId != nil
    }
}
