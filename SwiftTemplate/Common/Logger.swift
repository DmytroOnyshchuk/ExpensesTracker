//
//  Logger.swift
//  SwiftTemplate
//
//  Created by Dmytro Onyshchuk on 20.06.2025.
//  Copyright © 2025 Dmytro Onyshchuk. All rights reserved.
//


import UIKit
#if APP
import FirebaseCrashlytics
#endif

final class Logger: NSObject {
    
    enum LogType {
        case error, warning, info, onWatch, notification
        
        func indicator() -> String {
            switch self {
                case .error: return "❌"
                case .warning: return "⚠️"
                case .info: return "ℹ️"
                case .onWatch: return "⌚️"
                case .notification: return "✅"
            }
        }
    }
    
    enum LogDesination {
        case output, file, both
    }
    
    static let `default` = Logger()
    var outputLogingEnabled = true
#if APPSTORE
    var fileLoggingEnabled = false
#else
    var fileLoggingEnabled = true
#endif
    
    let fileUrl: URL? = FileManager
        .default
#if os(watchOS)
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
#else
        .urls(for: .documentDirectory, in: .userDomainMask)
#endif
        .first?
        .appendingPathComponent("debug.log")
    
    private let messageLengthLimit = 5 * 1024
    
    func logMessage(_ message: String, category: String = "", type: LogType = .info, indicator: String? = nil, destination: LogDesination = .both, logToCrashlytics: Bool = true) {
        let logText = "[\(Date().formatted("yyyy-MM-dd HH:mm:ss"))] \(indicator ?? type.indicator()) [\(category)] \(message)"
        
        if outputLogingEnabled, destination != .file {
            print(logText.prefix(messageLengthLimit))
        }
        
        if fileLoggingEnabled, destination != .output, let fileUrl = fileUrl, let logData = (logText + "\n").data(using: .utf8) {
            if let file = try? FileHandle(forWritingTo: fileUrl) {
                file.seekToEndOfFile()
                file.write(logData)
                file.closeFile()
            } else {
                try? logData.write(to: fileUrl, options: .atomic)
            }
        }
        
#if APP
        if logToCrashlytics {
            Crashlytics.crashlytics().log(logText)
        }
#endif
    }
    
    func errorLog(_ message: String, category: String = "", error: Error?) {
        guard let error = error else { return }
        
        logMessage("\(message): \(error)", category: category, type: .error)
    }
    
    func appendData(_ data: Data) {
        guard fileLoggingEnabled, let fileURL = fileUrl, let file = try? FileHandle(forWritingTo: fileURL) else { return }
        file.seekToEndOfFile()
        file.write(data)
        file.closeFile()
    }
    
}
