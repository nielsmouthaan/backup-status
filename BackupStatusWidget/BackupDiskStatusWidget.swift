//
//  BackupDiskStatusWidget.swift
//  BackupStatusWidget
//
//  Created by Niels Mouthaan on 20/11/2023.
//

import WidgetKit
import SwiftUI
import OSLog

struct Provider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> BackupDiskStatusEntry {
        let preferences = Preferences.load() ?? .demo
        return BackupDiskStatusEntry(date: Date(), configuration: BackupDiskStatusWidgetIntent(), preferences: preferences)
    }
    
    func snapshot(for configuration: BackupDiskStatusWidgetIntent, in context: Context) async -> BackupDiskStatusEntry {
        let preferences = Preferences.load() ?? .demo
        return BackupDiskStatusEntry(date: Date(), configuration: configuration, preferences: preferences)
    }
    
    func timeline(for configuration: BackupDiskStatusWidgetIntent, in context: Context) async -> Timeline<BackupDiskStatusEntry> {
        Logger.app.info("Timeline requested")
        let preferences = Preferences.load()
        let nowEntry = BackupDiskStatusEntry(date: Date(), configuration: configuration, preferences: preferences)
        let startOfTomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!) // Needed to update from Today to Tomorrow.
        let startOfTomorrowEntry = BackupDiskStatusEntry(date: startOfTomorrow, configuration: configuration, preferences: preferences)
        let startOfDayAfterTomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        let startOfDayAfterTomorrowEntry = BackupDiskStatusEntry(date: startOfDayAfterTomorrow, configuration: configuration, preferences: preferences) // Needed to update from Tomorrow to later.
        return Timeline(entries: [nowEntry, startOfTomorrowEntry, startOfDayAfterTomorrowEntry], policy: .after(startOfDayAfterTomorrow))
    }
}

struct BackupDiskStatusEntry: TimelineEntry {
    let date: Date
    let configuration: BackupDiskStatusWidgetIntent
    let preferences: Preferences?
}

struct BackupDiskStatusWidgetEntryView : View {
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            BackupDiskStatusWidgetView(preferences: entry.preferences, destination: entry.configuration.destination)
        }
    }
}

struct BackupDiskStatusWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: .widgetKind, intent: BackupDiskStatusWidgetIntent.self, provider: Provider()) { entry in
            BackupDiskStatusWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Backup Disk Status")
        .description("View when Time Machine made backups to a selected backup Disk.")
    }
}
