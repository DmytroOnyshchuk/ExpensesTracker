//
//  NSError.swift
//  OroveraAppClip
//
//  Created by Dmytro Onyshchuk on 18.11.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation

public extension NSError {
    
    convenience init(code: Int, userInfo: [String: Any]? = nil) {
        self.init(domain: "", code: 0, userInfo: userInfo)
    }
    
    convenience init(userInfo: [String: Any]? = nil) {
        self.init(code: 0, userInfo: userInfo)
    }
    
    convenience init(message: String) {
        self.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
    
}
