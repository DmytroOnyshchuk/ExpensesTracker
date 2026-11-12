//
//  View.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 07.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

extension View {
    func debugOverlay() -> some View {
        overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.appWhite, lineWidth: 1)
        )
    }
}
