import UIKit

extension Int {
	
	var asString: String { String(self) }
	
	var asCgFloat: CGFloat { CGFloat(self) }
	
	var asFloat: Float { Float(self) }
	
	var asDouble: Double { Double(self) }
	
	func asString(withUnits units: String) -> String { return "\(self) \(units)" }
	
	var asDigits: [Int] { String(self).compactMap { $0.wholeNumberValue } }
   
    var asBool: Bool {
        return self != 0
    }
    
	func degreesToRads() -> Double {
		return (Double(self) * .pi / 180)
	}
    
    func secondsToTime() -> String {
        
        let (h,m) = (self / 3600, ((self % 3600) / 60))
        
        let h_string = h < 10 ? "0\(h)" : "\(h)"
        let m_string =  m < 10 ? "0\(m)" : "\(m)"
        
        return "\(h_string):\(m_string)"
    }
    
    static var negativeRandom: Int {
        return -Int.random(in: 1...9999999)
    }
    
    static var random: Int {
        return Int.random(in: 1...9999999)
    }
    
}
