//
//  DatabaseManager+UsersDatabaseProtocol.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation
import RealmSwift

extension DatabaseManager {
    private func performDatabaseOperation<T>(_ block: @escaping () -> T?) -> T? {
        var result: T?
        
        DispatchQueue.global(qos: .userInitiated).sync {
            result = block()
        }
        return result
    }
}

extension DatabaseManager: CountriesDatabaseProtocol {
    
}
