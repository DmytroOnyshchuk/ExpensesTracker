import Foundation

final class UserManager {
	
    @UserDefaultCodable("currentLanguage", defaultValue: .English) var currentLanguage: Language!
    @UserDefaultCodable("lastApplicationEnvironment", defaultValue: .develop) var lastApplicationEnvironment: AppEnvironment!
    @UserDefault("fcmToken", defaultValue: nil) var fcmToken: String?
    @UserDefault("apiToken", defaultValue: nil) var apiToken: String?
    @UserDefault("userId", defaultValue: nil) var userId: String?
}

extension UserManager {
	
    func logout() {
        
        let savedEnvironment: AppEnvironment = lastApplicationEnvironment
        
        let defaults = UserDefaults(suiteName: Constants.groupIdentifier) ?? .standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
        lastApplicationEnvironment = savedEnvironment
        
//        databaseManager.deleteAll { (error) in
//            Logger.default.errorLog("Error delete all objects on logout", category: self.className, error: error)
//        }
        
    }
    
	func isLoggedIn() -> Bool {
		return userId != nil
	}
	
}
