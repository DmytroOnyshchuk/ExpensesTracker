import Foundation

extension UserDefaults {
    static var shared: UserDefaults = {
        guard let groupDefaults = UserDefaults(suiteName: Constants.groupIdentifier) else {
            Logger.default.logMessage("App group \(Constants.groupIdentifier) not available, using standard defaults", category: "UserDefaults", type: .warning)
            return .standard
        }
        return groupDefaults
    }()
}

@propertyWrapper
final class UserDefault<T> {
    private let key: UDKey
    private let defaultValue: T?
    private var cachedValue: T?
    private let queue = DispatchQueue(label: "com.userdefault.queue", attributes: .concurrent)
    
    init(_ key: UDKey, defaultValue: T?) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T? {
        get {
            queue.sync {
                if let cachedValue { return cachedValue }
                return (UserDefaults.shared.object(forKey: key.rawValue) as? T) ?? defaultValue
            }
        }
        set {
            queue.sync(flags: .barrier) { cachedValue = newValue }
            store(newValue)
        }
    }
    
    func reset() {
        queue.sync(flags: .barrier) { cachedValue = nil }
        store(defaultValue)
    }

    private func store(_ value: T?) {
        if let value {
            UserDefaults.shared.set(value, forKey: key.rawValue)
        } else {
            UserDefaults.shared.removeObject(forKey: key.rawValue)
        }
    }
}

@propertyWrapper
final class UserDefaultCodable<T: Codable> {
    private let key: UDKey
    private let defaultValue: T?
    private let enableCaching: Bool
    private var cachedValue: T?
    private let queue = DispatchQueue(label: "com.userdefaultcodable.queue", attributes: .concurrent)
    
    init(_ key: UDKey, defaultValue: T?, enableCaching: Bool = true) {
        self.key = key
        self.defaultValue = defaultValue
        self.enableCaching = enableCaching
    }
    
    var wrappedValue: T? {
        get {
            queue.sync {
                if let cachedValue, enableCaching { return cachedValue }
                guard let data = UserDefaults.shared.data(forKey: key.rawValue) else {
                    return defaultValue
                }
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    if enableCaching { cachedValue = decoded }
                    return decoded
                } catch {
                    Logger.default.logMessage("Failed to decode \(key.rawValue): \(error)", category: "UserDefaults", type: .error)
                    return defaultValue
                }
            }
        }
        set {
            if enableCaching {
                queue.sync(flags: .barrier) { cachedValue = newValue }
            }
            store(newValue)
        }
    }
    
    func reset() {
        queue.sync(flags: .barrier) { cachedValue = nil }
        store(defaultValue)
    }

    private func store(_ value: T?) {
        guard let value else {
            UserDefaults.shared.removeObject(forKey: key.rawValue)
            return
        }
        do {
            let data = try JSONEncoder().encode(value)
            UserDefaults.shared.set(data, forKey: key.rawValue)
        } catch {
            Logger.default.logMessage("Failed to encode \(key.rawValue): \(error)", category: "UserDefaults", type: .error)
        }
    }
}
