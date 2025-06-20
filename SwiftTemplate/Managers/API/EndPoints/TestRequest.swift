//
//  AcceptTerms.swift
//  Orovera
//
//  Created by Dmytro Onyshchuk on 24.01.2024.
//  Copyright © 2024 PeaksCircle. All rights reserved.
//

import Foundation

extension API.Request {
	
	final class TestRequest: EndpointPostItem<TestRequest.RequestBody> {
		
		override var path: String { "test/test" }
		
		init(test: String) {
			super.init(.init(test: test))
		}
		
		struct RequestBody: Encodable {
			let test: String
		}
		
	}
	
}
