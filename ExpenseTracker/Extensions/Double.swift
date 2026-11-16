//
//  Double.swift
//  OroveraAppClip
//
//  Created by Dmytro Onyshchuk on 14.11.2022.
//  Copyright © 2022 PeaksCircle. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    private func getInputNumberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = .current
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = .zero
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = " "
        return formatter
    }

    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded(.down) / divisor
    }

    func asCurrencyString() -> String {
        getInputNumberFormatter().string(from: NSNumber(value: self)) ?? String(self).trimmingCharacters(in: .whitespaces)
    }
}
