import Foundation

extension API {

	enum ApiError: Error {
		
		case errorType(ErrorType), message(String), other(Error), unknown
		
		var localizedDescription: String {
			switch self {
				case .errorType(let errorType):
					switch errorType {
						case .versionError:
							return "API_VERSION_ERROR".localized
						case .codeExpired:
							return "API_NEW_CODE".localized
						case .incorrectPin:
							return "API_WRONG_CODE".localized
						case .customError(let customError):
							return customError?.text ?? customError?.code ?? "API_UNKNOWN_ERROR".localized
						case .partialCustomError(let customError):
							return customError?.text ?? customError?.code ?? "API_UNKNOWN_ERROR".localized
						case .unknown(let errorString):
							return errorString ?? "API_UNKNOWN_ERROR".localized
						default:
							return "API_UNKNOWN_ERROR".localized
					}
				case .message(let message):
					return message
				case .other(let error):
					return error.localizedDescription
				case .unknown:
					return "API_UNKNOWN_ERROR".localized

			}
		}
		
	}

}
