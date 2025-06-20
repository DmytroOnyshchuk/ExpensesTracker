import Foundation

enum ResponseStatus: String, Decodable {
	case ok, error
	
	init(from decoder: Decoder) throws {
		let value = try decoder.singleValueContainer().decode(String.self)
		switch value.lowercased() {
			case ResponseStatus.ok.rawValue: self = .ok
			default: self = .error
		}
	}
}
