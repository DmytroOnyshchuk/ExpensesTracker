//
//  DigitPad.swift
//  ExpensesTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct DigitPadView: View {
    @Binding var input: String
    
    let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { symbol in
                        Button(action: {
                            handleTap(symbol)
                        }) {
                            Text(symbol)
                                .font(.title)
                                .frame(width: 70, height: 70)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
    }
    
    private func handleTap(_ symbol: String) {
        switch symbol {
        case "⌫":
            input = String(input.dropLast())
        default:
            input.append(symbol)
        }
    }
}
