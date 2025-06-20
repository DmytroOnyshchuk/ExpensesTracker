import Foundation

extension Array {
	
    subscript (safe index: Index) -> Iterator.Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
    
    @discardableResult
	mutating func appendNonNil(_ element: Element?) -> Bool {
		guard let element = element else { return false }
		append(element)
		return true
	}
	
	func element(at index: Int) -> Element? {
		guard index >= 0, index < count else { return nil }
		return self[index]
	}
	
	var second: Element? { count > 1 ? self[1] : nil }
	
}

extension Array where Element: Equatable {
	
	func containtsOneOf(_ elements: [Element]) -> Bool {
		for item in elements {
			if contains(item) {
				return true
			}
		}
		return false
	}
	
}

extension Array where Element : Equatable {
    
    @discardableResult mutating func remove(object: Element) -> Bool {
        var result = false
        while let index = firstIndex(of: object) {
            self.remove(at: index)
            result = true
        }
        return result
    }
    
    @discardableResult mutating func remove(objects: [Element]) -> Bool {
        var result = false
        objects.forEach {
            if remove(object: $0) {
                result = true
            }
        }
        return result
    }
    
}
