//
//  Logger+Extensions.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 21/11/2023.
//

import Foundation
import OSLog

extension Logger {
    
    static let app = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "app")
}
