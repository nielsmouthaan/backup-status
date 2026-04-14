//
//  BackupDiskStatusWidgetView.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 21/11/2023.
//

import SwiftUI
import WidgetKit

struct BackupDiskStatusWidgetView: View {
    
    var preferences: Preferences?
    var destination: Preferences.Destination?
    var widgetFamilyOverride: WidgetFamily? = nil
    @Environment(\.widgetRenderingMode) private var renderingMode
    @Environment(\.widgetFamily) private var widgetFamily
    
    var body: some View {
        VStack(alignment: .leading) {
            if let preferences {
                if let destination = destination ?? preferences.lastDestination {
                    Text(destination.volumeName)
                        .font(.title2)
                        .padding(.bottom)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(renderingFamily == .systemLarge ? "Last backups" : "Last backup")
                            .textCase(.uppercase)
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                        if destination.snapshots.isEmpty {
                            HStack {
                                Text(renderingFamily == .systemLarge ? "No backups" : "No backup")
                                    .fontWeight(.semibold)
                                Image(systemName: renderingMode == .vibrant ? "exclamationmark.triangle" : "exclamationmark.triangle.fill")
                                    .foregroundStyle(renderingMode == .vibrant ? .primary : Color(.red))
                            }
                        } else {
                            Group {
                                if renderingFamily == .systemLarge {
                                    ForEach(Array(destination.snapshots.sorted().reversed().prefix(11).enumerated()), id: \.element) { index, element in
                                        HStack {
                                            Text(formattedDate(element))
                                                .fontWeight(index == 0 ? .semibold : .regular)
                                            if index == 0, let color = warningIndicatorColor(destination: destination) {
                                                Image(systemName: renderingMode == .vibrant ? "exclamationmark.triangle" : "exclamationmark.triangle.fill")
                                                    .foregroundStyle(renderingMode == .vibrant ? .primary : color)
                                            }
                                        }
                                    }
                                } else {
                                    HStack {
                                        Text(formattedDate(destination.lastSnapshot!))
                                            .fontWeight(.semibold)
                                        if let color = warningIndicatorColor(destination: destination) {
                                            Image(systemName: renderingMode == .vibrant ? "exclamationmark.triangle" : "exclamationmark.triangle.fill")
                                                .foregroundStyle(renderingMode == .vibrant ? .primary : color)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                    DiskUsageView(used: destination.bytesUsed, available: destination.bytesAvailable)
                    HStack(spacing: 0) {
                        Text(formatBytes(destination.bytesUsed))
                        Text(renderingFamily == .systemSmall ? " / " : " of ")
                            .foregroundStyle(.tertiary)
                        Text(formatBytes(destination.bytesUsed + destination.bytesAvailable))
                        if renderingFamily != .systemSmall {
                            Text(" used")
                                .foregroundStyle(.tertiary)
                        }
                        if renderingFamily != .systemSmall {
                            Spacer()
                            Image(systemName: destination.isEncrypted ? "lock" : "lock.open")
                            Text(" ")
                            Image(systemName: destination.isNetwork ? "network" : "network.slash")
                        }
                    }
                    .lineLimit(1)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                } else {
                    VStack {
                        Text("No Backup Disk")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .padding(.bottom, 5)
                        Text("Configure Time Machine to use this widget.")
                    }
                    .multilineTextAlignment(.center)
                }
            } else {
                VStack {
                    Text("Not Set Up")
                        .font(.title3)
                        .fontWeight(.semibold)
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
    
    
    private func warningIndicatorColor(destination: Preferences.Destination) -> Color? {
        if let lastSnapshot = destination.lastSnapshot {
            if Date().timeIntervalSince(lastSnapshot) > (3 * 24 * 60 * 60) {
                return .red
            } else if Date().timeIntervalSince(lastSnapshot) > (24 * 60 * 60) {
                return .orange
            }
        }
        return nil
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        if renderingFamily == .systemSmall {
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

    private var renderingFamily: WidgetFamily {
        widgetFamilyOverride ?? widgetFamily
    }
}
