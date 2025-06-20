import UIKit

extension UIColor {
	
	// Example: UIColor(hex: "#000000", alpha: 0.2)
	public convenience init(hex: String, alpha a: CGFloat? = nil) {
		var red: CGFloat = 0.0
		var green: CGFloat = 0.0
		var blue: CGFloat = 0.0
		var alpha: CGFloat = a ?? 1.0
		
		var hex = hex;
		
		if !hex.hasPrefix("#"), hex.count == 6 { hex = "#\(hex)" }
		
		let index = hex.index(hex.startIndex, offsetBy: 1)
		let hexString = String(hex[index...])
		let scanner = Scanner(string: hexString)
		var hexValue: CUnsignedLongLong = 0
		if scanner.scanHexInt64(&hexValue) {
			if hexString.count == 6 {
				red   = CGFloat((hexValue & 0xFF0000) >> 16) / 255.0
				green = CGFloat((hexValue & 0x00FF00) >> 8)  / 255.0
				blue  = CGFloat(hexValue & 0x0000FF) / 255.0
			} else if hexString.count == 8 {
				red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
				green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
				blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
				alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
			} else {
				fatalError("Invalid RGB string, length should be 7 or 9")
			}
		} else {
			fatalError("Scan hex error")
		}
		
		self.init(red:red, green:green, blue:blue, alpha:alpha)
	}
	
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return String(format:"#%06x", rgb)
    }
    
}
