//
//  AppEnviroment.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 14.10.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation

enum AppEnvironment: String, Codable {
    
    case develop
    case stage
    case production
    
    static var current: AppEnvironment {
#if PROD
        return .production
#elseif STAGE
        return .stage
#else
        return .develop
#endif
    }
    
}
