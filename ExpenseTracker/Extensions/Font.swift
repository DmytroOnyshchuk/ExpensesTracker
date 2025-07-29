//
//  Font.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 04.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

extension Font {
    
    static func appLight(_ size: CGFloat) -> Font {
        .custom("e-Ukraine-Light", size: size)
    }
    
    static func appRegular(_ size: CGFloat) -> Font {
        .custom("e-Ukraine-Regular", size: size)
    }
    
    static func appMedium(_ size: CGFloat) -> Font {
        .custom("e-Ukraine-Medium", size: size)
    }
}
