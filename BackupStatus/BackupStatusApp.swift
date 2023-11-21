//
//  BackupStatusApp.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 20/11/2023.
//

import SwiftUI

@main
struct BackupStatusApp: App {
    
    @StateObject private var preferenceFile = PreferenceFile()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
        .environmentObject(preferenceFile)
    }
}
