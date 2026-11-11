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
        case error, warning, info, notification
        
        func indicator() -> String {
            switch self {
            case .error: "❌"
            case .warning: "⚠️"
            case .info: "ℹ️"
            case .notification: "✅"
            }
        }
    }
    
    enum LogDestination {
        case output, file, both
    }
    
    static let `default` = Logger()
    
    var outputLoggingEnabled = true
    #if APPSTORE
    var fileLoggingEnabled = false
    #else
    var fileLoggingEnabled = true
    #endif
    
    private let messageLengthLimit = 8 * 1024
    private let fileQueue = DispatchQueue(label: "logger.file.queue", qos: .utility)
    private let maxLogFileSize = 10 * 1024 * 1024 // 10 MB
    
    private(set) var fileUrl: URL?
    
    private override init() {
        super.init()
        setupLogFile()
    }
    
    private func setupLogFile() {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        fileUrl = documentsUrl.appendingPathComponent("debug.log")
        
        guard let fileUrl else { return }
        
        if !FileManager.default.fileExists(atPath: fileUrl.path) {
            if !FileManager.default.createFile(atPath: fileUrl.path, contents: nil, attributes: nil) {
                print("### Logger: Failed to create log file at \(fileUrl.path)")
            }
        }
    }
    
    func logMessage(_ message: String, category: String = String(), type: LogType = .info, indicator: String? = nil, destination: LogDestination = .both, logToCrashlytics: Bool = false) {
        let logText = "[\(Date().string(with: .server))] \(indicator ?? type.indicator()) [\(category)] \(message)"
        
        if outputLoggingEnabled && destination != .file {
            print(logText.prefix(messageLengthLimit))
        }
        
        if fileLoggingEnabled, destination != .output, let fileUrl {
            fileQueue.async {
                self.writeToLogFile(logText, fileUrl: fileUrl)
            }
        }
        
        #if APP
        if logToCrashlytics {
            Crashlytics.crashlytics().log(logText)
        }
        #endif
    }
    
    private func writeToLogFile(_ message: String, fileUrl: URL) {
        let text = message + "\n"
        guard let data = text.data(using: .utf8) else { return }
        
        rotateLogFileIfNeeded(fileUrl: fileUrl)
        
        if let outputStream = OutputStream(url: fileUrl, append: true) {
            outputStream.open()
            defer { outputStream.close() }
            
            let bytesWritten = data.withUnsafeBytes { buffer in
                guard let baseAddress = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                    return -1
                }
                return outputStream.write(baseAddress, maxLength: data.count)
            }
            
            if bytesWritten < 0, let error = outputStream.streamError {
                print("### Logger: Failed to write to log file: \(error)")
            }
        } else {
            // Use FileHandle if OutputStream fails
            if let fileHandle = try? FileHandle(forWritingTo: fileUrl) {
                defer { try? fileHandle.close() }
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
            } else {
                print("### Logger: Unable to open file for logging at \(fileUrl)")
            }
        }
    }
    
    private func rotateLogFileIfNeeded(fileUrl: URL) {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: fileUrl.path),
              let fileSize = attributes[.size] as? Int,
              fileSize > maxLogFileSize else {
            return
        }
        
        // Create backup and clear current log
        let backupUrl = fileUrl.deletingPathExtension().appendingPathExtension("old.log")
        
        do {
            // Remove old backup if exists
            if FileManager.default.fileExists(atPath: backupUrl.path) {
                try FileManager.default.removeItem(at: backupUrl)
            }
            
            // Move current log to backup
            try FileManager.default.moveItem(at: fileUrl, to: backupUrl)
            
            // Create new empty log file
            FileManager.default.createFile(atPath: fileUrl.path, contents: nil, attributes: nil)
            
        } catch {
            print("### Logger: Failed to rotate log file: \(error)")
        }
    }
    
    func logError(_ message: String, error: Error?, category: String = "", logToCrashlytics: Bool = false) {
        guard let error else { return }
        logMessage("\(message): \(error)", category: category, type: .error, logToCrashlytics: false)
        #if APP
        if logToCrashlytics {
            Crashlytics.crashlytics().log(logText)
        }
        #endif
    }
    
    func clearLogs() {
        guard let fileUrl else { return }
        fileQueue.async {
            do {
                try "".write(to: fileUrl, atomically: true, encoding: .utf8)
            } catch {
                print("### Logger: Failed to clear log file: \(error)")
            }
        }
    }
}
