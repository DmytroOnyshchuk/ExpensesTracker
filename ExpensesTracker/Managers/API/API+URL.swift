import Foundation

extension API {
    
    struct Url {
        
        private static var config: APIConfiguration.Type {
            return APIConfiguration.self
        }
        
        static var server: URL {
            URL(string: "\(config.baseServer):\(config.contentPort)/")!
        }
        
        static var current: URL {
            URL(string: "\(config.baseServer):\(config.apiPort)")!
        }
        
        static func contentUrl(content: String? = nil) -> URL? {
            guard let content = content else { return nil }
            let baseUrl = "\(config.baseServer):\(config.contentPort)/"
            return content.isEmpty ? URL(string: baseUrl) : URL(string: baseUrl + content)
        }
        
    }
    
}
