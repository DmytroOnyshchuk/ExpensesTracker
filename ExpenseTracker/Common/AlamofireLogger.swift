//
//  AlamofireLogger.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//

import Alamofire
import Foundation

extension DataResponse {
    func cURLDescription() -> String {
        let statusCode = response.map { $0.statusCode } ?? -1
        let requestDescription = request.map { "\($0) \($0.httpMethod!) \(statusCode)" } ?? "nil"
        let responseDescription = response.map { $0.headers.sorted().compactMap { "-H \"\($0.name): \($0.value)\"" }.joined(separator: "\n\t")
        } ?? "nil"
        let responseBody = data.map { String(decoding: $0, as: UTF8.self) } ?? "None"
        let metricsDescription = metrics.map { "\($0.taskInterval.duration)s" } ?? "None"

        return """
         \(requestDescription)
         \(responseDescription)
         -d "\(responseBody)"
         Time: \(metricsDescription)
        """
    }

    func logResponse() {
        let requestMethod = request?.httpMethod ?? "ERROR"
        let requestUrl = request?.url?.absoluteString ?? "UNKNOWN"
        let requestHeader = request?.headers ?? [:]

        let prettyRequestBody = request?.httpBody?.prettyPrintedJSONString
        let rawRequestBody = String(data: (request?.httpBody ?? "NONE".data(using: .utf8)!), encoding: .utf8)!
        let requestBody = prettyRequestBody ?? rawRequestBody as NSString

        let prettyResponseBody = data?.prettyPrintedJSONString
        let rawResponseBody = String(data: data ?? "NONE".data(using: .utf8)!, encoding: .utf8)!
        let responseBody = prettyResponseBody ?? rawResponseBody as NSString

        let type: Logger.LogType = switch result {
        case .success:
            .info
        case .failure:
            .error
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
                                  logToCrashlytics: false)

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
                                  destination: .output)
    }
}

final class AlamofireLogger: EventMonitor {
    func request<Value>(_: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        response.logResponse()
    }
}
