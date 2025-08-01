import Foundation

extension Sequence {
	
	func grouped<GroupingType: Hashable>(by key: (Iterator.Element) -> GroupingType) -> [[Iterator.Element]] {
		var groups: [GroupingType: [Iterator.Element]] = [:]
		var groupsOrder: [GroupingType] = []
		forEach { element in
			let key = key(element)
			if case nil = groups[key]?.append(element) {
				groups[key] = [element]
				groupsOrder.append(key)
			}
		}
		return groupsOrder.map { groups[$0]! }
	}
	
}
