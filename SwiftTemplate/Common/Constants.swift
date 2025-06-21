//
//  Constants.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
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
    
    static let defaultCredential = Credentials(login: "test@example.com", password: "123456")
    
}
