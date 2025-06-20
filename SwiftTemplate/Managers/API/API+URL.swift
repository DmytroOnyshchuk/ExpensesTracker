import Foundation

extension API {
    
    struct Url {
        
        static var current: URL {
            switch AppEnvironment.current {
            case .develop:
                return URL(string: "https://api-live.orovera.app/dev/")!
            case .stage:
                return URL(string: "https://api-live.orovera.app/prod/stage/")!
            case .production:
                return URL(string: "https://api-live.orovera.app/prod/")!
            }
        }
        
        static var upload: URL { URL(string: "https://upload.orovera.app")! }
        
		static func getURL(url: String? = nil, with path: String, versionTwo: Bool = true) -> URL {
            var result: URL
			
			let currentUrl: URL = (url != nil) ? URL(string: url!)! : current
			
			if versionTwo {
				result = currentUrl.appendingPathComponent("v2.0").appendingPathComponent(path)
			}else{
				result = currentUrl.appendingPathComponent(path)
			}
			
            if let removedPercentEncoding = result.absoluteString.removingPercentEncoding, let url = URL(string: removedPercentEncoding) {
                return url
            } else {
                return result
            }
        }
        
        static func getUploadURL(with path: String) -> URL {
            return upload.appendingPathComponent(path)
        }
        
        static func getOfflineTransactionURL(content: String) -> URL {
            var url = URL(string: "https://frog.4ek.cc/frog/")!
            url.appendPathComponent(content)
            url.appendQueryItem(name: "source", value: "mobile")
            return url
        }
        
    }
}
