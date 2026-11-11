import Foundation

enum UDKey: String {
    case currentLanguage = "UDKey.currentLanguage"
    case lastApplicationEnvironment = "UDKey.lastApplicationEnvironment"
    case fcmToken = "UDKey.fcmToken"
    case apiToken = "UDKey.apiToken"
    case userId = "UDKey.userId"
}

final class UserManager: NSObject {
    @UserDefaultCodable(.currentLanguage, defaultValue: .English) var currentLanguage: Language!
    @UserDefaultCodable(.lastApplicationEnvironment, defaultValue: .develop) var lastApplicationEnvironment: AppEnvironment!
    @UserDefault(.fcmToken, defaultValue: nil) var fcmToken: String?
    @UserDefault(.apiToken, defaultValue: nil) var apiToken: String?
    @UserDefault(.userId, defaultValue: nil) var userId: String?
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

        @Inject var databaseManager: DatabaseManagerProtocol
        databaseManager.deleteAll { error in
            Logger.default.logError("Error delete all objects on logout", error: error, category: self.className)
        }
        Logger.default.logMessage("Logout end", category: className)
    }

    func isLoggedIn() -> Bool {
        userId != nil
    }
}
