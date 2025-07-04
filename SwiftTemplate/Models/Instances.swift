//
//  Instances.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//


import Foundation
import RealmSwift

final class Instances: NSObject {
    
    static let shared = Instances()
    
    private let actualSchemaVersion: UInt64 = 20
    
    lazy var realmInstance: Realm = {
        Logger.default.logMessage("Realm instance call", category: self.className)
        
#if os(iOS)
        let fileURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Constants.groupIdentifier)!
            .appendingPathComponent("default.realm")
        
        let configuration = Realm.Configuration(fileURL: fileURL, schemaVersion: actualSchemaVersion, deleteRealmIfMigrationNeeded: true)
#else
        let configuration = Realm.Configuration(schemaVersion: actualSchemaVersion, deleteRealmIfMigrationNeeded: true)
#endif
        
        do {
            let realm = try Realm(configuration: configuration)
            return realm
        } catch {
            Logger.default.errorLog("Failed to create Realm instance", category: self.className, error: error)
            let fallbackConfig = Realm.Configuration(inMemoryIdentifier: "FallbackRealm")
            return try! Realm(configuration: fallbackConfig)
        }
    }()
    
    func importRealmDatabase(from url: URL) -> Bool {
        Logger.default.logMessage("Importing Realm database from: \(url)", category: self.className)
        
#if os(iOS)
        
        let destinationURL = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: Constants.groupIdentifier)!
            .appendingPathComponent("default.realm")
        
        let didStartAccessing = url.startAccessingSecurityScopedResource()
        
        defer {
            if didStartAccessing {
                url.stopAccessingSecurityScopedResource()
            }
        }
        
        do {
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            let configuration = Realm.Configuration(fileURL: destinationURL, schemaVersion: actualSchemaVersion, deleteRealmIfMigrationNeeded: true)
            realmInstance = try Realm(configuration: configuration)
            Logger.default.logMessage("Successfully imported and reconfigured Realm instance.", category: self.className)
            return true
        } catch {
            Logger.default.logMessage("Failed to import Realm database: \(error)", category: self.className, type: .error)
            return false
        }
        
#else
        Logger.default.logMessage("Importing is only supported on iOS.", category: self.className, type: .error)
        return false
#endif
    }
}
