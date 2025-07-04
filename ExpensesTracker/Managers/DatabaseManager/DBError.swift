//
//  DBError.swift
//  HealthTracker
//
//  Created by Bohdan Pokhidnia on 05.07.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation

enum DBError: Error {
    case isInvalidate, other(Error), timeout
    
    var localizedDescription: String {
        switch self {
            case .isInvalidate:
                return "Object is invalidate"
            case .other(let error):
                return error.localizedDescription
            case .timeout:
                return "Write transaction timed out"
        }
    }
}
