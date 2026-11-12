//
//  AmountInput.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 11.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

/// An amount typed on the digit pad.
///
/// Stores the pressed keys rather than a number, so it can show exactly what was typed ("12," or "0.5")
/// and still return the value in minor units.
struct AmountInput {
    enum Key: Hashable {
        case digit(Int)
        case decimalSeparator
        case backspace
    }

    /// How many digits are accepted after the separator.
    private static let fractionLength = 2

    /// Typed digits without the separator, most significant first.
    private(set) var digits: [Int] = []
    /// How many digits of `digits` belong to the whole part; `nil` until the separator is pressed.
    private(set) var wholeLength: Int?

    var isEmpty: Bool { digits.isEmpty }

    /// The typed value in minor units: "12.5" is 1250.
    var amount: Int {
        let wholeLength = wholeLength ?? digits.count
        let missingFractionDigits = wholeLength + Self.fractionLength - digits.count
        let padded = digits + Array(repeating: 0, count: missingFractionDigits)
        return padded.reduce(0) { $0 * 10 + $1 }
    }

    /// Text for the display, or `nil` if nothing has been typed yet.
    var text: String? {
        guard !isEmpty else { return nil }
        guard let wholeLength else { return digits.map(String.init).joined() }

        let whole = digits.prefix(wholeLength).map(String.init).joined()
        let fraction = digits.dropFirst(wholeLength).map(String.init).joined()
        return fraction.isEmpty ? "\(whole)," : "\(whole).\(fraction)"
    }

    mutating func tap(_ key: Key) {
        let previousAmount = amount

        switch key {
        case let .digit(digit):
            append(digit)
        case .decimalSeparator:
            guard wholeLength == nil else { return }
            if isEmpty {
                digits = [0]
            }
            wholeLength = digits.count
        case .backspace:
            if wholeLength == digits.count {
                wholeLength = nil
            } else if !isEmpty {
                digits.removeLast()
            }
        }

        // When the amount is erased down to zero, the input resets completely and the keypad shows the hint again.
        if amount == 0, previousAmount != 0 {
            reset()
        }
    }

    mutating func reset() {
        self = AmountInput()
    }

    private mutating func append(_ digit: Int) {
        guard let wholeLength, digits.count == wholeLength + Self.fractionLength else {
            digits.append(digit)
            return
        }

        // The fraction part is full, extra digits are ignored.
        // Exception: after "0.00" a non-zero digit replaces the last zero ("0.00" + 5 → "0.05").
        guard digit != 0, digits.allSatisfy({ $0 == 0 }) else { return }
        digits[digits.count - 1] = digit
    }
}
