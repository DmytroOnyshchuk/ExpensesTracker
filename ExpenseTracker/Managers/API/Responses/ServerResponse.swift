import UIKit

enum ErrorType: CaseIterable {
	static var allCases: [ErrorType] {
		return [.codeExpired, .incorrectPin, .userIsBlocked, .deviceIsBlocked, .versionError, .customError(nil), .partialCustomError(nil), .unknown(nil)]
	}
	
	case codeExpired
	case incorrectPin
	case userIsBlocked
	case deviceIsBlocked
	case versionError
	case customError(CustomError?)
	case partialCustomError(CustomError?)
	case unknown(String?)
	
	func codeError() -> String {
		switch self {
			case .codeExpired:
				return "CODE_EXPIRED"
			case .incorrectPin:
				return "INCORRECT_PIN"
			case .userIsBlocked:
				return "USER_IS_BLOCKED"
			case .deviceIsBlocked:
				return "DEVICE_IS_BLOCKED"
			case .versionError:
				return "VERSION_ERROR"
			case .customError:
				return "CUSTOM_ERROR"
			case .partialCustomError:
				return "PARTIAL_CUSTOM_ERROR"
			case .unknown(let errorString):
				return errorString ?? "UNKNOWN_ERROR"
		}
	}
	
	
}

extension ErrorType: Decodable {
	init(from decoder: Decoder) throws {
		do {
			let rawValue = try? decoder.singleValueContainer().decode(String.self)
			for item in ErrorType.allCases {
				if item.codeError() == rawValue {
					self = item
					return
				}
			}
			self = .unknown(rawValue)
		}
	}
}

struct CustomError: Decodable {
	var code: String
	var text: String
}

final class ServerResponse<T: Decodable>: Decodable {
	
	private enum CodingKeys: String, CodingKey {
		case status, error, message, data
	}
	
	var status: ResponseStatus?
	var error: ErrorType?
	var message: String?
	var data: T?
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.status = try? container.decodeIfPresent(ResponseStatus.self, forKey: .status)
		self.error = try? container.decodeIfPresent(ErrorType.self, forKey: .error)
		self.message = try? container.decodeIfPresent(String.self, forKey: .message)
		
		switch error {
			case .customError:
				if let customError = try? container.decodeIfPresent(CustomError.self, forKey: .data) {
					self.error = .customError(customError)
				}
			case .partialCustomError:
				if let customError = try? container.decodeIfPresent(CustomError.self, forKey: .data) {
					self.error = .partialCustomError(customError)
				}
			default:
				break
		}
		
		if let data = try? container.decodeIfPresent(T.self, forKey: .data) {
			self.data = data
		} else {
			do {
				self.data = try container.decode(T?.self, forKey: .data)
			} catch {
				Logger.default.logMessage("\(T.self) decoding error: \(error)", category: "API", type: .error)
				if self.error == nil {
					self.error = .unknown("\(T.self) decoding error: \(error)")
				}
				self.data = nil
			}
		}
	}
	
}

extension ServerResponse {
	
	var success: Bool { status == .ok }
	
}
