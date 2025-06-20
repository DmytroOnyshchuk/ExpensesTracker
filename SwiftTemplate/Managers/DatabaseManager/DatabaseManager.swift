//
//  DatabaseManager.swift
//  HealthTracker
//
//  Created by Bohdan Pokhidnia on 01.07.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation
import RealmSwift

final class DatabaseManager: NSObject {
    typealias CompletionHandler = ((_ error: DBError?) -> Void)
    typealias ActionHandler = (() -> Void)
    
    internal var realm = Instances.shared.realmInstance
}

extension DatabaseManager {
    
}
