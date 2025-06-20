//
//  GetMerchants.swift
//  Toad
//
//  Created by Alexandr on 04.08.2021.
//

import Foundation
import Alamofire

extension API.Request {
	class GetMerchants: EndpointPostItem<GetMerchants.RequestBody> {
		override var path: String { "keyboard_get_merchant" }
		
        override var headers: HTTPHeaders? { .init(["token" : AppGroupsManager.apgm.token ?? ""]) }
		
		init() {
			super.init(.init())
		}
		
		struct RequestBody: Encodable {
		}
	}
}

//extension API.Request {
//
//	class GetMerchants: EndpointPostItem<GetMerchants.RequestBody> {
//
//		override var path: String { "keyboard_get_merchant" }
//
//		override var headers: HTTPHeaders? { .init(["token" : "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6OCwicGhvbmUiOiIzODAwMDAwMDAwMDAiLCJpYXQiOjE2Mjc4ODk0Mzh9.RmAlSl6mFRgypawV86xM0nKU8MwyNXIZGcDCWpEsZD0"]) }
//
//		init() {
//			super.init(.init())
//		}
//
//		struct RequestBody: Encodable {
//
//		}
//	}
//}
