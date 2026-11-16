import UIKit

extension Int {
    func asString(withUnits units: String) -> String { "\(self) \(units)" }

    var asDigits: [Int] { String(self).compactMap { $0.wholeNumberValue } }

    func degreesToRads() -> Double {
        Double(self) * .pi / 180
    }

    func secondsToTime() -> String {
        let (h, m) = (self / 3600, (self % 3600) / 60)

        let h_string = h < 10 ? "0\(h)" : "\(h)"
        let m_string = m < 10 ? "0\(m)" : "\(m)"

        return "\(h_string):\(m_string)"
    }

    static var negativeRandom: Int {
        -Int.random(in: 1 ... 9999999)
    }

    static var random: Int {
        Int.random(in: 1 ... 9999999)
    }

    func getAmount() -> String {
        var paymentAmount: Double { double / 100.0 }
        let sumInString = paymentAmount.asCurrencyString()
        return sumInString
    }
}
