//
//  Dictionary.swift
//  Orovera
//
//  Created by Dmitry S on 09.11.2021.
//

import Foundation

extension Dictionary where Key: Hashable {
	
	func asJSONString() -> String? {
		do {
			let data = try JSONSerialization.data(withJSONObject: self, options: [.withoutEscapingSlashes])
			return String(data: data, encoding: .utf8)
		} catch {
			return nil
		}
	}
	
}
