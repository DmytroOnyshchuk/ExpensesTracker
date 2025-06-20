//
//  AppEnvironment.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

enum AppEnvironment: String, Codable {
    
    case develop
    case production
    
    static var current: AppEnvironment {
#if PROD
        return .production
#else
        return .develop
#endif
    }
    
}
