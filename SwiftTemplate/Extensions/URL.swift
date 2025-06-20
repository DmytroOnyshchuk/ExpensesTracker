//
//  URL.swift
//  Orovera
//
//  Created by Dmitry S on 08.11.2021.
//

import Foundation

extension URL {
	
	func appending(_ queryItem: String, value: String?) -> URL {
		guard var urlComponents = URLComponents(string: absoluteString) else { return absoluteURL }
		let queryItem = URLQueryItem(name: queryItem, value: value)
		var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
		queryItems.append(queryItem)
		urlComponents.queryItems = queryItems
		return urlComponents.url!
	}
	
	mutating func appendQueryItem(name: String, value: String?) {
		guard var urlComponents = URLComponents(string: absoluteString) else { return }
		let queryItem = URLQueryItem(name: name, value: value)
		var queryItems: [URLQueryItem] = urlComponents.queryItems ??  []
		queryItems.append(queryItem)
		urlComponents.queryItems = queryItems
		self = urlComponents.url!
	}
	
}
