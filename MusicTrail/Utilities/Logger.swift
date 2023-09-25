//
//  Logger.swift
//  MusicTrail
//
//  Created by Davy Chuon on 9/22/23.
//

import UIKit
import os.log

class Logger {
    static let shared = Logger()
    private let logQueue = DispatchQueue(label: "com.MusicTrail.logging")

    private let subsystem: String
    private let category: String
    
    private init() {
        subsystem = "com.MusicTrail"
        category = "Debug Log"
    }

    func log(_ message: String, logLevel: OSLogType) {
        logQueue.async {
            let logger = OSLog(subsystem: self.subsystem, category: self.category)
            os_log("%@", log: logger, type: logLevel, message)
        }
    }

    func debug(_ message: String, toggle: Bool?=true) {
        guard let toggle = toggle else { return }
        
        if toggle {
            log(message, logLevel: .debug)
        }
    }

    func info(_ message: String) {
        log(message, logLevel: .info)
    }

    func error(_ message: String) {
        log(message, logLevel: .error)
    }
}

