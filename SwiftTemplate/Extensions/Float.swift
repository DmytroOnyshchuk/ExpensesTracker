import Foundation

extension Float {
    
    var asInt: Int { Int(self) }
	
	func rounded(toPlaces places: Int) -> Float {
		let divisor = pow(10.0, Float(places))
		return (self * divisor).rounded(.down) / divisor
	}
    
}
