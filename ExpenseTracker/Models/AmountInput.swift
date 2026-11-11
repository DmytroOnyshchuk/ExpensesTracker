//
//  AmountInput.swift
//  ExpenseTracker
//
//  Created by Dmytro Onyshchuk on 11.11.2026.
//  Copyright © 2026 Dmytro Onyshchuk. All rights reserved.
//

import Foundation

/// Сумма, которую набирают на цифровой клавиатуре.
///
/// Хранит нажатые клавиши, а не число: так можно показать ровно то, что набрано («12,» или «0.5»),
/// и при этом отдать значение в копейках.
struct AmountInput {
    enum Key: Hashable {
        case digit(Int)
        case decimalSeparator
        case backspace
    }

    /// Сколько цифр принимается после разделителя.
    private static let fractionLength = 2

    /// Набранные цифры без разделителя, старшие первыми.
    private(set) var digits: [Int] = []
    /// Сколько цифр из `digits` относится к целой части; `nil`, пока разделитель не нажат.
    private(set) var wholeLength: Int?

    var isEmpty: Bool { digits.isEmpty }

    /// Набранное значение в копейках: «12.5» — это 1250.
    var amount: Int {
        let wholeLength = wholeLength ?? digits.count
        let missingFractionDigits = wholeLength + Self.fractionLength - digits.count
        let padded = digits + Array(repeating: 0, count: missingFractionDigits)
        return padded.reduce(0) { $0 * 10 + $1 }
    }

    /// Текст для экрана или `nil`, если ещё ничего не набрано.
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

        // Когда сумма стирается до нуля, ввод сбрасывается целиком и клавиатура снова показывает подсказку.
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

        // Дробная часть заполнена, лишние цифры игнорируются.
        // Исключение: после «0.00» ненулевая цифра заменяет последний ноль («0.00» + 5 → «0.05»).
        guard digit != 0, digits.allSatisfy({ $0 == 0 }) else { return }
        digits[digits.count - 1] = digit
    }
}
