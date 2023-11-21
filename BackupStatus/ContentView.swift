//
//  ContentView.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 20/11/2023.
//

import SwiftUI
import LaunchAtLogin

struct ContentView: View {
    
    @StateObject private var startAtLaunch = StartAtLaunch()
    @EnvironmentObject private var preferenceFile: PreferencesFile
    
    var body: some View {
        VStack {
            VStack {
                Text("Backup Status")
                    .font(.largeTitle)
                    .padding(.bottom, 3)
                Text("Backup Status introduces a widget for your Mac, allowing you to monitor the status of Time Machine right from your desktop or Notification Center.")
                    .padding(.bottom, 3)
                Text("Follow the below instructions to set up Backup Status.")
            }
            .padding(.bottom)
            VStack {
                Text("1. Grant permission")
                    .font(.title)
                    .padding(.bottom, 3)
                Text("Backup Status requires read-only access to your Time Machine configuration in order to determine its status. Click *Grant Permission* and select *\(URL.preferencesFile.lastPathComponent)* from the displayed directory.")
                Button("Grant permission") {
                    preferenceFile.grantAccess()
                }
                .disabled(preferenceFile.accessibleURL != nil)
            }
            .opacity(preferenceFile.accessibleURL != nil ? 0.5 : 1)
            .padding(.bottom)
            VStack {
                Text("2. Start at launch")
                    .font(.title)
                    .padding(.bottom, 3)
                Text("Backup Status needs to automatically run in the background to observe status changes so the widget can display them.")
                Button("Start at launch") {
                    startAtLaunch.enabled = true
                }
                .disabled(startAtLaunch.enabled)
            }
            .opacity(startAtLaunch.enabled ? 0.5 : 1)
            .padding(.bottom)
            VStack {
                Text("3. Add widget")
                    .font(.title)
                    .padding(.bottom, 3)
                Text("Add the Backup Status widget to your desktop or Notification Center.")
                Link("View instructions", destination: URL(string: "https://support.apple.com/guide/mac-help/add-and-customize-widgets-mchl52be5da5/mac")!)
            }
            .padding(.bottom)
            
        }
        .padding()
        .frame(width: 480, height: 520)
    }
}

#Preview {
    ContentView()
}
