//
//  BackupStatusWidget.swift
//  BackupStatusWidget
//
//  Created by Niels Mouthaan on 20/11/2023.
//

import WidgetKit
import SwiftUI
import OSLog

struct Provider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        let preferences = Preferences.load() ?? .demo
        return SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), preferences: preferences)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let preferences = Preferences.load() ?? .demo
        return SimpleEntry(date: Date(), configuration: configuration, preferences: preferences)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let preferences = Preferences.load()
        let entry = SimpleEntry(date: Date(), configuration: configuration, preferences: preferences)
        Logger.app.info("Timeline requested")
        return Timeline(entries: [entry], policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let preferences: Preferences?
}

struct BackupStatusWidgetEntryView : View {
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            WidgetView(preferences: entry.preferences)
        }
    }
}

struct BackupStatusWidget: Widget {
    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: .widgetKind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            BackupStatusWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}
