//
//  Constant.swift
//  HealthTracker
//
//  Created by Denis Kuznetsov on 21.10.2021.
//  Copyright © 2021 PeaksCircle. All rights reserved.
//

import Foundation

struct Constants {
    
    static var groupIdentifier: String {
#if PROD
        return "group.com.dmytroon.template.ios"
#else
        return "group.com.dmytroon.template.dev"
#endif
    }
    
    static let testId: String = "testId"
}
