//
//  DigitPad.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 01.07.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import SwiftUI

struct DigitPadView: View {
    @Binding var inputAmount: Int
    @State private var dotSequenceNumber: Int = -1
    @State private var inputNumbers: [Int] = [] {
        didSet {
            guard !inputNumbers.isEmpty else {
                inputAmount = 0
                return
            }
            
            if dotSequenceNumber != -1 {
                
                if inputNumbers.count > dotSequenceNumber + 2 {
                    if inputNumbers.last == 0 {
                        inputNumbers = oldValue
                        reloadInputNumbers()
                        return
                    }else{
                        if oldValue.allSatisfy({ $0 == 0 }) {
                            inputNumbers.remove(at: inputNumbers.count - 2)
                        }else{
                            inputNumbers = oldValue
                            reloadInputNumbers()
                            return
                        }
                    }
                }
                
                var mainAmount: [Int] = []
                var secondAmount: [Int] = []
                for (index, number) in inputNumbers.enumerated() {
                    if index < dotSequenceNumber {
                        mainAmount.append(number)
                    }else{
                        secondAmount.append(number)
                    }
                }
                
                let inputTextMain = mainAmount.reduce(0, { $0 * 10 + $1 }) * 100
                let inputTextCents = secondAmount.reduce(0, { $0 * 10 + $1 })
                
                if secondAmount.first == 0 {
                    inputAmount = inputTextMain + inputTextCents
                }else{
                    inputAmount = inputTextMain + (inputTextCents >= 10 ? inputTextCents : inputTextCents * 10)
                }
            }else{
                inputAmount = inputNumbers.reduce(0, { $0 * 10 + $1 }) * 100
            }
        }
    }
    
    private let buttons = [
        ["1", "2", "3"],
        ["4", "5", "6"],
        ["7", "8", "9"],
        [".", "0", "⌫"]
    ]
    
    private func reloadInputNumbers(){
        let temp = inputNumbers
        inputNumbers = temp
    }
    
    private var displayText: String {
        guard !inputNumbers.isEmpty else { return "Введите расход" }
        
        var main = ""
        var decimal = ""
        
        for (index, digit) in inputNumbers.enumerated() {
            if dotSequenceNumber != -1, index >= dotSequenceNumber {
                decimal.append(String(digit))
            } else {
                main.append(String(digit))
            }
        }
        
        if dotSequenceNumber != -1 {
            // Если точка уже нажата
            if decimal.isEmpty {
                return "\(main),"
            } else if decimal.count == 1 {
                return "\(main).\(decimal)"
            } else {
                return "\(main).\(decimal.prefix(2))"
            }
        } else {
            return "\(main)"
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text(displayText)
                .font(inputNumbers.isEmpty ? .appLight(24) : .appLight(32))
                .foregroundColor(inputNumbers.isEmpty ? .appLabel : .white)
                .frame(height: 64)
            
            ForEach(buttons, id: \.self) { row in
                HStack(spacing: 12) {
                    ForEach(row, id: \.self) { symbol in
                        Button(action: {
                            handleTap(symbol)
                        }) {
                            Text(symbol)
                                .font(.appMedium(36))
                                .frame(width: 75, height: 75)
                                .background(Color.appLabel.opacity(0.1))
                                .foregroundColor(.white)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .onChange(of: inputAmount) {
            if inputAmount == 0 {
                inputNumbers = []
                dotSequenceNumber = -1
            }
        }
    }
    
    private func handleTap(_ symbol: String) {
        switch symbol {
            case "⌫":
                if inputNumbers.count == dotSequenceNumber {
                    dotSequenceNumber = -1
                    return
                }
                guard !inputNumbers.isEmpty else { return }
                inputNumbers.removeLast()
            case ".":
                if inputNumbers.isEmpty && dotSequenceNumber == -1 {
                    inputNumbers = [0]
                    dotSequenceNumber = inputNumbers.count
                }else if dotSequenceNumber == -1 {
                    dotSequenceNumber = inputNumbers.count
                }
            default:
               // if symbol.asInt == 0, inputNumbers == [0], dotSequenceNumber == -1 {
                //    return
                //}
                inputNumbers.append(symbol.asInt)
        }
    }
}
