//
//  WidgetView.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 21/11/2023.
//

import SwiftUI

private extension Color {
    static let darkGreen = Color(red: 0.0, green: 0.5, blue: 0.0)
}

struct WidgetView: View {
    
    @State var preferences: Preferences?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let preferences {
                if let destination = preferences.lastDestination {
                    Text(destination.volumeName)
                        .font(.title2)
                    .padding(.bottom)
                    Text("Last Backup")
                        .textCase(.uppercase)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 0) {
                        if let lastBackup = destination.lastBackup {
                            Text(lastBackup, format:.relative(presentation: .numeric, unitsStyle: .wide))
                                .foregroundStyle(.green)
                        } else {
                            #warning("TODO: No backups")
                        }
                    }
                        .font(.title3)
                    Spacer()
                    ProgressView(value: Double(destination.bytesUsed), total: Double(destination.bytesAvailable + destination.bytesUsed))
                        .progressViewStyle(LinearProgressViewStyle())
                        .tint(.green)
                    #warning("TODO: Dynamic color")
                    HStack {
                        Text("\(formatBytes(8002555904)) of \(formatBytes(8002555904 + 22773600256))")
                            .textCase(.uppercase)
                        Spacer()
                        Image(systemName: destination.isEncrypted ? "lock" : "lock.open")
                        Image(systemName: destination.isNetwork ? "network" : "network.slash")
                    }
                        .font(.footnote)
                } else {
                    
                }
            } else {
                VStack {
                    Text("Not Set Up")
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 5)
                    Text("Run the app **Backup Status** to set up this widget.")
                }
                .multilineTextAlignment(.center)
            }
        }
        .fontDesign(.monospaced)
        .frame(maxWidth: .infinity)
    }
    
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

#Preview("Not Configured") {
    Group {
        VStack {
            Group {
                WidgetView(preferences: nil)
                    .frame(width: 165, height: 165)
                WidgetView(preferences: nil)
                    .frame(width: 345, height: 165)
                WidgetView(preferences: nil)
                    .frame(width: 345, height: 345)
            }
            .padding()
            .background(.white)
            .cornerRadius(25)
        }
        .padding()
    }
}

#Preview("Preferences") {
    Group {
        VStack {
            Group {
                WidgetView(preferences: Preferences.demo)
                    .frame(width: 165, height: 165)
                WidgetView(preferences: Preferences.demo)
                    .frame(width: 345, height: 165)
                WidgetView(preferences: Preferences.demo)
                    .frame(width: 345, height: 345)
            }
            .padding()
            .background(.white)
            .cornerRadius(25)
        }
        .padding()
    }
}
