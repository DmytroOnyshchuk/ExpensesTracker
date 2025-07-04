import Foundation

final class EmptyResponseData: Decodable {
}

final class EmptyResponse: Decodable {
	
	private enum CodingKeys: String, CodingKey {
		case status, error, data
	}
	
	var status: ResponseStatus?
	var error: ErrorType?
	var data: Any?
	
	required init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.status = try? container.decodeIfPresent(ResponseStatus.self, forKey: .status)
		self.error = try? container.decodeIfPresent(ErrorType.self, forKey: .error)
		
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
		
	}
	
}

extension EmptyResponse {
	
	var success: Bool { status == .ok }
	
}
