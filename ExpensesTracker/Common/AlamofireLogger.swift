//
//  AlamofireLogger.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//


import Foundation
import Alamofire

extension DataResponse {
	
	func cURLDescription() -> String {
		let statusCode = self.response.map { $0.statusCode } ?? -1
		let requestDescription = self.request.map { "\($0) \($0.httpMethod!) \(statusCode)" } ?? "nil"
		let responseDescription = self.response.map { $0.headers.sorted().compactMap { "-H \"\($0.name): \($0.value)\"" }.joined(separator: "\n\t")
		} ?? "nil"
		let responseBody = self.data.map { String(decoding: $0, as: UTF8.self) } ?? "None"
		let metricsDescription = self.metrics.map { "\($0.taskInterval.duration)s" } ?? "None"
		
		return """
   \(requestDescription)
   \(responseDescription)
   -d "\(responseBody)"
   Time: \(metricsDescription)
  """
	}
	
	func logResponse() {
		let requestMethod = self.request?.httpMethod ?? "ERROR"
		let requestUrl = self.request?.url?.absoluteString ?? "UNKNOWN"
		let requestHeader = self.request?.headers ?? [:]
		
		let prettyRequestBody = self.request?.httpBody?.prettyPrintedJSONString
		let rawRequestBody = String(data: (self.request?.httpBody ?? "NONE".data(using: .utf8)!), encoding: .utf8)!
		let requestBody = prettyRequestBody ?? rawRequestBody as NSString
		
		let prettyResponseBody = self.data?.prettyPrintedJSONString
		let rawResponseBody = String(data: (self.data ?? "NONE".data(using: .utf8)!), encoding: .utf8)!
		let responseBody = prettyResponseBody ?? rawResponseBody as NSString
		
		let type: Logger.LogType
		switch self.result {
			case .success:
				type = .info
			case .failure:
				type = .error
		}
		
		Logger.default.logMessage("""
   Request: [\(requestMethod)] \(requestUrl)
   Headers: \(requestHeader.dictionary)
   Body: \(requestBody)
   Response: \(responseBody)
   """,
								  category: "API",
								  type: type,
								  destination: .file,
								  logToCrashlytics: false
		)
		
		//        if responseBody.count > 15 * 1024 {
		//            responseBody = "<Long Response (\(responseBody.count / 1024)KB)>" as NSString
		//        }
		
		Logger.default.logMessage("""
   Request: [\(requestMethod)] \(requestUrl)
   Headers: \(requestHeader.dictionary)
   Body: \(requestBody)
   Response: \(responseBody)
   """,
								  category: "API",
								  type: type,
								  destination: .output
		)
	}
	
}

final class AlamofireLogger: EventMonitor {
	
	func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
		response.logResponse()
	}
	
}
