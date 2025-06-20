import Foundation
import Alamofire

@propertyWrapper
struct NullEncodable<T>: Encodable where T: Encodable {
	
	var wrappedValue: T?
	
	init(wrappedValue: T?) {
		self.wrappedValue = wrappedValue
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch wrappedValue {
			case .some(let value): try container.encode(value)
			case .none: try container.encodeNil()
		}
	}
}


class EndpointBase: P_ApiEndpoint {
	
	var url: String? { nil }
	var path: String { "" }
	var versionTwo: Bool { true }
	var httpMethod: HTTPMethod { .get }
	var headers: HTTPHeaders? { nil }
	var encoding: ParameterEncoding { URLEncoding.default }
	var decoder: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}
	var params: Parameters? { nil }
	var destination: DownloadRequest.Destination? { nil }
	
}

class EndpointBaseUpload: EndpointBase, P_ApiUploadEndpoint {
	
	var uploadData: Data { return Data() }
	var fileName: String? { return String() }
	
}

class EndpointBaseItem<T: Encodable>: EndpointBase {
	
	private let item: T?
	
	init(_ item: T? = nil, _ closure: (() -> (T?))? = nil) {
		self.item = item ?? closure?()
	}
	
	// MARK: - P_ApiEndpoint
	override var params: Parameters? {
		guard let item = item else { return nil }
		do {
			let data = try JSONEncoder().encode(item)
			return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
		} catch {
			fatalError(error.localizedDescription)
		}
	}
	
}

class EndpointGet: EndpointBase {
	
	override var httpMethod: HTTPMethod { .get }
	override var encoding: ParameterEncoding { URLEncoding.default }
	
}

class EndpointGetItem<T: Encodable>: EndpointBaseItem<T> {
	
	override var httpMethod: HTTPMethod { .get }
	override var encoding: ParameterEncoding { URLEncoding.default }
	
}

class EndpointPost: EndpointBase {
	
	override var httpMethod: HTTPMethod { .post }
	override var encoding: ParameterEncoding { JSONEncoding.default }
	
}

class EndpointPostItem<T: Encodable>: EndpointBaseItem<T> {
	
	override var httpMethod: HTTPMethod { .post }
	override var encoding: ParameterEncoding { JSONEncoding.default }
	
}

class EndpointPut: EndpointBase {
	
	override var httpMethod: HTTPMethod { .put }
	override var encoding: ParameterEncoding { JSONEncoding.default }
	
}

class EndpointPutItem<T: Encodable>: EndpointBaseItem<T> {
	
	override var httpMethod: HTTPMethod { .put }
	override var encoding: ParameterEncoding { JSONEncoding.default }
	
}

class EndpointDownload: EndpointBase {
	
	override var httpMethod: HTTPMethod { .get }
	override var encoding: ParameterEncoding { JSONEncoding.default }
	
}

class EndpointUpload: EndpointBaseUpload {
	
	override var httpMethod: HTTPMethod { .post }
	override var encoding: ParameterEncoding { URLEncoding.default }
	
}

class EndpointDelete: EndpointBase {
	
	override var httpMethod: HTTPMethod { .delete }
	override var encoding: ParameterEncoding { URLEncoding.default }
	
}

class EndpointDeleteItem<T: Encodable>: EndpointBaseItem<T> {
	
	override var httpMethod: HTTPMethod { .delete }
	override var encoding: ParameterEncoding { JSONEncoding.default }
	
}
