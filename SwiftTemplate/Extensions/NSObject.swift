import Foundation

extension NSObject {
    
    @discardableResult
    func config(_ action: (NSObject) -> ()) -> Self {
        action(self)
        return self
    }
    
    static var name: String { String(describing: Self.self) }
    
     var className: String {
         return String(describing: type(of: self)).components(separatedBy: ".").last!
     }
     
     class var className: String {
         return String(describing: self).components(separatedBy: ".").last!
     }  
    
}
