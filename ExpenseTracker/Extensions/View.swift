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
        self.overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(Color.white, lineWidth: 1)
        )
    }
}
