import Foundation

fileprivate extension UserDefaults {
    static var shared: UserDefaults = {
        guard let groupDefaults = UserDefaults(suiteName: Constants.groupIdentifier) else {
            Logger.default.logMessage("App group \(Constants.groupIdentifier) not available, using standard defaults", category: "UserDefaults", type: .warning)
            return .standard
        }
        return groupDefaults
    }()
}

@propertyWrapper
struct UserDefault<T> {
    
    let key: String
    let defaultValue: T?
    
    private(set) var storedValue: T?
    
    init(_ key: String, defaultValue: T?) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T? {
        get {
            guard storedValue == nil else { return storedValue }
            guard let object = UserDefaults.shared.object(forKey: key) as? T else {
                return defaultValue
            }
            return object
        }
        set {
            storedValue = newValue
            if newValue == nil {
                UserDefaults.shared.removeObject(forKey: key)
            } else {
                UserDefaults.shared.set(newValue, forKey: key)
            }
        }
    }
    
}

@propertyWrapper
struct UserDefaultCodable<T: Codable> {
    
    let key: String
    let defaultValue: T?
    let enableCaching: Bool
    
    private(set) var storedValue: T?
    
    init(_ key: String, defaultValue: T?, enableCaching: Bool = true) {
        self.key = key
        self.defaultValue = defaultValue
        self.enableCaching = enableCaching
    }
    
    var wrappedValue: T? {
        mutating get {
            if storedValue != nil && enableCaching {
                return storedValue
            }
            guard let data = UserDefaults.shared.data(forKey: key) else {
                return defaultValue
            }
            do {
                let value = try JSONDecoder().decode(T.self, from: data)
                if enableCaching {
                    storedValue = value
                }
                return value
            } catch {
                Logger.default.logMessage("Failed to decode value for key \(key): \(error)", category: "UserDefaults", type: .error)
                return defaultValue
            }
        }
        set {
            if enableCaching {
                storedValue = newValue
            }
            if newValue == nil {
                UserDefaults.shared.removeObject(forKey: key)
            } else {
                do {
                    let data = try JSONEncoder().encode(newValue)
                    UserDefaults.shared.set(data, forKey: key)
                } catch {
                    Logger.default.logMessage("Failed to encode value for key \(key): \(error)", category: "UserDefaults", type: .error)
                }
            }
        }
    }
    
}
