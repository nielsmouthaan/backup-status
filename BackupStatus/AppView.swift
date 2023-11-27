//
//  AppView.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 20/11/2023.
//

import SwiftUI

struct AppView: View {
    
    @StateObject private var startAtLaunch = StartAtLaunch()
    @ObservedObject var preferenceFile: PreferencesFile
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image("Icon")
                    Text("Backup Status")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
                Text("*Backup Status* introduces a widget for your Mac, allowing you to view the status of *Time Machine* right from your desktop or *Notification Center*.")
                Text("Follow the below instructions to set it up.")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
            VStack(alignment: .leading, spacing: 8) {
                Text("1. Grant Permission")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.title)
                    .padding(.bottom, 3)
                Text("*Backup Status* requires read-only access to your *Time Machine* configuration in order to determine its status.")
                Text("Click *Grant Permission* and select *\(URL.preferencesFile.lastPathComponent)* from the displayed directory.")
                Button(action: {
                    preferenceFile.grantAccess()
                }) {
                    Text("Grant Permission")
                        .font(.headline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 3)
                .disabled(preferenceFile.url != nil)
            }
            .opacity(preferenceFile.url != nil ? 0.3 : 1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
            VStack(alignment: .leading, spacing: 8) {
                Text("2. Start at Launch")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.title)
                    .padding(.bottom, 3)
                Text("*Backup Status* needs to automatically run in the background to observe status changes so the widget can display them.")
                Button(action: {
                    startAtLaunch.enabled = true
                }) {
                    Text("Start at Launch")
                        .font(.headline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 3)
                .disabled(startAtLaunch.enabled)
            }
            .opacity(startAtLaunch.enabled ? 0.3 : 1)
            .padding(.bottom)
            VStack(alignment: .leading, spacing: 8) {
                Text("3. Add Widget")
                    .frame(maxWidth: .infinity, alignment: .center)
                    .font(.title)
                    .padding(.bottom, 3)
                Text("Add the *Backup Status* widget to your desktop or *Notification Center*.")
                Button(action: {
                    NSWorkspace().open(URL(string: "https://support.apple.com/guide/mac-help/add-and-customize-widgets-mchl52be5da5/mac")!)
                }) {
                    Text("View Instructions")
                        .font(.headline)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom)
            Spacer(minLength: 30)
            HStack {
                Text("Made by [Niels Mouthaan](http://x.com/nielsmouthaan)")
                Text("—")
                Button("Quit & Uninstall") {
                    NSWorkspace.shared.open(URL(string: "https://github.com/nielsmouthaan/backup-status#how-can-i-uninstall-backup-status")!)
                    NSApplication.shared.terminate(self)
                }
                .buttonStyle(.link)
            }
            .font(.footnote)
        }
        .monospaced()
        .padding()
        .frame(width: 480)
        .background(.background)
        .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    AppView(preferenceFile: PreferencesFile())
}
