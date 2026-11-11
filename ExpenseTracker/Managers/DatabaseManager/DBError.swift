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
            "Object is invalidate"
        case let .other(error):
            error.localizedDescription
        case .timeout:
            "Write transaction timed out"
        }
    }
}
