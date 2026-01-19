//
//  UserDefaults+Extensions.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 21/11/2023.
//

import Foundation

extension UserDefaults {
    
    static var shared: UserDefaults {
        UserDefaults(suiteName: "group.nl.nielsmouthaan.backup-status")!
    }
}
