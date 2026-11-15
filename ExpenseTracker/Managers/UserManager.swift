import Foundation

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
}

final class UserManager {
    static let shared = UserManager()
    
    private init() {}
    
    @UserDefaultCodable(.currentLanguage, defaultValue: .English) var currentLanguage: Language!
    @UserDefaultCodable(.lastApplicationEnvironment, defaultValue: .develop) var lastApplicationEnvironment: AppEnvironment!
    @UserDefault(.fcmToken, defaultValue: nil) var fcmToken: String?
    @UserDefault(.apiToken, defaultValue: nil) var apiToken: String?
    @UserDefault(.userId, defaultValue: nil) var userId: String?
    @UserDefaultCodable(.theme, defaultValue: ThemePreset.system) var theme: ThemePreset!
    @UserDefault(.soundsEnabled, defaultValue: true) var soundsEnabled: Bool!
}

extension UserManager {
    @MainActor
    func logout() {
        let savedEnvironment: AppEnvironment = lastApplicationEnvironment

        let defaults = UserDefaults(suiteName: Constants.groupIdentifier) ?? .standard
        let dictionary = defaults.dictionaryRepresentation()
        for key in dictionary.keys {
            defaults.removeObject(forKey: key)
        }
        lastApplicationEnvironment = savedEnvironment
        fcmToken = nil
        apiToken = nil
        userId = nil

        Logger.default.logMessage("Logout end", category: "UserManager")
    }

    func isLoggedIn() -> Bool {
        userId != nil
    }
}
