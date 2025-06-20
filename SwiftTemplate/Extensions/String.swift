import Foundation
import UIKit

extension String {
    
    var asInt: Int {
        return Int(self) ?? 0
    }
    
    var asFloat: Float    {
        return Float(self) ?? 0.0
    }
    
    var asDouble: Double    {
        return Double(self) ?? 0.0
    }
    
    var asBool: Bool {
        return Bool(self) ?? false
    }
    
	func toURL() -> URL? {
		return URL(string: self)
	}
	
	var onlyNumbers: String {
		components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
	}
	
	var onlyPhoneNumbers: String {
		return filter("+0123456789".contains)
	}
	
	func isValidEmail() -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		
		let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
		return emailTest.evaluate(with: self)
	}
	
	func isValidPhone() -> Bool {
		let types: NSTextCheckingResult.CheckingType = [.phoneNumber]
		guard let detector = try? NSDataDetector(types: types.rawValue) else { return false }
		if let match = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count)).first?.phoneNumber {
			return match == self
		} else {
			return false
		}
	}
    
    func isValidJSON() -> Bool {
        guard !self.isBlank, let data = self.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }
    
    var isBlank: Bool {
        return trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var convertToDictionary: [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    var convertToData: Data? {
        return self.data(using: .utf8)
    }
    
    var convertToSeconds: Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            let seconds = (components.hour! * 60 + components.minute!) * 60
            return seconds
        } else {
            return nil
        }
    }
    
    var convertToMinutes: Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        if let date = dateFormatter.date(from: self) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: date)
            let minutes = components.hour! * 60 + components.minute!
            return minutes
        } else {
            return nil
        }
    }
    
    func fromIso8601String() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: self)
    }
    
    var convertToTime: String? {
        let hours = self.asInt / 3600
        let minutes = (self.asInt % 3600) / 60
        
        let formattedTime = String(format: "%02d:%02d", hours, minutes)
        return formattedTime
    }
	
}

extension String {
	
	func height(forWidth width: CGFloat, font: UIFont) -> CGFloat {
		return self.boundingRect(with: CGSize(width: width, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil).height
	}
	
	func width(forHeight height: CGFloat, font: UIFont) -> CGFloat {
		return self.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: height), options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil).width
	}
	
}
