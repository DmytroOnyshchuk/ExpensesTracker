import Foundation

extension API {
    enum ApiError: Error {
        case errorType(ErrorType), message(String), other(Error), unknown

        var localizedDescription: String {
            switch self {
            case let .errorType(errorType):
                switch errorType {
                case .versionError:
                    "API_VERSION_ERROR".localized
                case .codeExpired:
                    "API_NEW_CODE".localized
                case .incorrectPin:
                    "API_WRONG_CODE".localized
                case let .customError(customError):
                    customError?.text ?? customError?.code ?? "API_UNKNOWN_ERROR".localized
                case let .partialCustomError(customError):
                    customError?.text ?? customError?.code ?? "API_UNKNOWN_ERROR".localized
                case let .unknown(errorString):
                    errorString ?? "API_UNKNOWN_ERROR".localized
                default:
                    "API_UNKNOWN_ERROR".localized
                }
            case let .message(message):
                message
            case let .other(error):
                error.localizedDescription
            case .unknown:
                "API_UNKNOWN_ERROR".localized
            }
        }
    }
}
