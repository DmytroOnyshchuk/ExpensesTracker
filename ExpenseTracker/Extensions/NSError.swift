//
//  NSError.swift
//  OroveraAppClip
//
//  Created by Dmytro Onyshchuk on 18.11.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation

extension NSError {
    public convenience init(code _: Int, userInfo: [String: Any]? = nil) {
        self.init(domain: "", code: 0, userInfo: userInfo)
    }

    public convenience init(userInfo: [String: Any]? = nil) {
        self.init(code: 0, userInfo: userInfo)
    }

    public convenience init(message: String) {
        self.init(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
