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
        Logger.app.info("Placeholder requested")
        return SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        Logger.app.info("Snapshot requested")
        return SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        Logger.app.info("Timeline requested")
        let nowEntry = SimpleEntry(date: Date(), configuration: configuration)
        let startOfTomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!) // Needed to update from Today to Tomorrow.
        let startOfTomorrowEntry = SimpleEntry(date: startOfTomorrow, configuration: configuration)
        let startOfDayAfterTomorrow = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        let startOfDayAfterTomorrowEntry = SimpleEntry(date: startOfDayAfterTomorrow, configuration: configuration) // Needed to update from Tomorrow to later.
        return Timeline(entries: [nowEntry, startOfTomorrowEntry, startOfDayAfterTomorrowEntry], policy: .after(startOfDayAfterTomorrow))
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct BackupStatusWidgetEntryView : View {
    
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            WidgetView()
        }
        .onAppear {
            Logger.app.info("Widget appeared")
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
