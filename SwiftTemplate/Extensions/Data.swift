import Foundation

extension Data {
    
    public enum DataUnits: String {
        case byte, kilobyte, megabyte, gigabyte
    }
    
    func getSizeIn(_ type: DataUnits)-> Double {
        
        var size: Double = 0.0
        
        switch type {
            case .byte:
                size = Double(self.count)
            case .kilobyte:
                size = Double(self.count) / 1024
            case .megabyte:
                size = Double(self.count) / 1024 / 1024
            case .gigabyte:
                size = Double(self.count) / 1024 / 1024 / 1024
        }
        
        return size
    }
    
    func imageToBase64EncodedString() -> String {
        let base64String = self.base64EncodedString(options: .lineLength64Characters)
        return "data:image/jpeg;base64,\(base64String)"
    }
    
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString
    }
    
}
