//
//  ConfigurationAppIntent.swift
//  Backup Status Widget
//
//  Created by Niels Mouthaan on 20/11/2023.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    
    static var title: LocalizedStringResource = "Backup Status"
    static var description = IntentDescription("Shows the status of your Time Machine backups.")

    @Parameter(title: "Backup Disk") var destination: Preferences.Destination?
}
