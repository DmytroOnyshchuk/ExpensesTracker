import Foundation

typealias JSON = [String: Any]

extension Data {
    public enum DataUnits: String {
        case byte, kilobyte, megabyte, gigabyte
    }

    func getSizeIn(_ type: DataUnits) -> Double {
        var size = 0.0

        switch type {
        case .byte:
            size = Double(count)
        case .kilobyte:
            size = Double(count) / 1024
        case .megabyte:
            size = Double(count) / 1024 / 1024
        case .gigabyte:
            size = Double(count) / 1024 / 1024 / 1024
        }

        return size
    }

    func imageToBase64EncodedString() -> String {
        let base64String = base64EncodedString(options: .lineLength64Characters)
        return "data:image/jpeg;base64,\(base64String)"
    }

    func json() -> JSON? {
        do {
            if let json = try JSONSerialization.jsonObject(with: self, options: []) as? JSON {
                return json
            }
            
        } catch {
            debugPrint(error)
        }
        
        return nil
    }
    
    var prettyPrintedJSONString: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding: .utf8) else { return nil }
        return prettyPrintedString
    }
}
