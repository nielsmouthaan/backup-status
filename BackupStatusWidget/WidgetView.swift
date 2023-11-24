//
//  WidgetView.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 21/11/2023.
//

import SwiftUI
import WidgetKit

struct WidgetView: View {
    
    var preferences: Preferences?
    @Environment(\.widgetRenderingMode) private var renderingMode
    @Environment(\.widgetFamily) private var widgetFamily
    @State private var textWidth: CGFloat = 0
    var widgetFamilyForPreviewing: WidgetFamily? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            if let preferences {
                if let destination = preferences.lastDestination {
                    Text(destination.volumeName)
                        .font(.title2)
                        .padding(.bottom)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(widgetFamilyForRendering == .systemLarge ? "Last backups" : "Last backup")
                            .textCase(.uppercase)
                            .font(.subheadline)
                            .foregroundStyle(.tertiary)
                        if destination.snapshots.isEmpty {
                            HStack {
                                Text(widgetFamilyForRendering == .systemLarge ? "No backups" : "No backup")
                                    .fontWeight(.semibold)
                                Image(systemName: renderingMode == .vibrant ? "exclamationmark.triangle" : "exclamationmark.triangle.fill")
                                    .foregroundStyle(renderingMode == .vibrant ? .primary : Color(.red))
                            }
                        } else {
                            Group {
                                if widgetFamilyForRendering == .systemLarge {
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
                        Text(widgetFamilyForRendering == .systemSmall ? " / " : " of ")
                            .foregroundStyle(.tertiary)
                        Text(formatBytes(destination.bytesUsed + destination.bytesAvailable))
                        if widgetFamilyForRendering != .systemSmall {
                            Text(" available")
                                .foregroundStyle(.tertiary)
                        }
                        if widgetFamilyForRendering != .systemSmall {
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
        if widgetFamilyForRendering == .systemSmall {
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
    
    private var widgetFamilyForRendering: WidgetFamily {
        if let widgetFamilyForPreviewing {
            return widgetFamilyForPreviewing
        } else {
            return widgetFamily
        }
    }
}

#Preview("Not Set Up") {
    Group {
        VStack {
            Group {
                VStack {
                    WidgetView(preferences: nil, widgetFamilyForPreviewing: .systemSmall)
                        .padding()
                }
                .frame(width: 165, height: 165)
                VStack {
                    WidgetView(preferences: nil, widgetFamilyForPreviewing: .systemMedium)
                        .padding()
                }
                .frame(width: 345, height: 165)
                VStack {
                    WidgetView(preferences: nil, widgetFamilyForPreviewing: .systemSmall)
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
                    WidgetView(preferences: Preferences.demo, widgetFamilyForPreviewing: .systemSmall)
                        .padding()
                }
                .frame(width: 165, height: 165)
                VStack {
                    WidgetView(preferences: Preferences.demo, widgetFamilyForPreviewing: .systemMedium)
                        .padding()
                }
                .frame(width: 345, height: 165)
                VStack {
                    WidgetView(preferences: Preferences.demo, widgetFamilyForPreviewing: .systemLarge)
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
