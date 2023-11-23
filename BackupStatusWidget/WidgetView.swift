//
//  WidgetView.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 21/11/2023.
//

import SwiftUI

struct WidgetView: View {
    
    var preferences = Preferences.load()
    @Environment(\.widgetRenderingMode) private var renderingMode
    @Environment(\.widgetFamily) var widgetFamily
    @State private var textWidth: CGFloat = 0
    
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
                        .foregroundStyle(.tertiary)
                    HStack {
                        if let lastBackup = destination.lastBackup {
                            Text(formattedDate(lastBackup))
                                .bold()
                        } else {
                            Text("No backup made")
                                .foregroundStyle(renderingMode == .vibrant ? .primary : Color.red)
                                .bold()
                        }
                    }
                        .font(.title3)
                    Spacer()
                    DiskUsageView(used: destination.bytesUsed, available: destination.bytesAvailable)
                    HStack(spacing: 0) {
                        Text(formatBytes(destination.bytesUsed))
                        Text(widgetFamily == .systemSmall ? " / " : " of ")
                            .foregroundStyle(.tertiary)
                        Text(formatBytes(destination.bytesUsed + destination.bytesAvailable))
                        if widgetFamily != .systemSmall {
                            Text(" available")
                                .foregroundStyle(.tertiary)
                        }
                        if widgetFamily != .systemSmall {
                            Spacer()
                            Image(systemName: destination.isEncrypted ? "lock" : "lock.open")
                            Text(" ")
                            Image(systemName: destination.isNetwork ? "network" : "network.slash")
                        }
                    }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
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
    
    private func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB, .useTB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func colorForDate(_ date: Date) -> Color {
        if Date().timeIntervalSince(date) < (24 * 60 * 60) {
            return .primary
        } else if Date().timeIntervalSince(date) < (3 * 24 * 60 * 60) {
            return .orange
        } else {
            return .red
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if widgetFamily == .systemSmall {
            if Calendar.current.isDateInToday(date) {
                formatter.dateStyle = .none
                formatter.timeStyle = .short
            } else {
                formatter.dateStyle = .short
                formatter.timeStyle = .none
            }
        } else {
            formatter.dateStyle = .short
            formatter.timeStyle = .short
        }
        formatter.doesRelativeDateFormatting = true
        return formatter.string(from: date)
    }
}

#Preview("Not Configured") {
    Group {
        VStack {
            Group {
                VStack {
                    WidgetView(preferences: nil)
                        .padding()
                }
                .frame(width: 165, height: 165)
                VStack {
                    WidgetView(preferences: nil)
                        .padding()
                }
                .frame(width: 345, height: 165)
                VStack {
                    WidgetView(preferences: nil)
                        .padding()
                }
                .frame(width: 345, height: 345)
            }
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
                VStack {
                    WidgetView(preferences: Preferences.demo)
                        .padding()
                }
                .frame(width: 165, height: 165)
                VStack {
                    WidgetView(preferences: Preferences.demo)
                        .padding()
                }
                .frame(width: 345, height: 165)
                VStack {
                    WidgetView(preferences: Preferences.demo)
                        .padding()
                }
                .frame(width: 345, height: 345)
            }
            .background(.white)
            .cornerRadius(25)
        }
        .padding()
    }
}
