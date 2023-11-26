//
//  BackupDiskStatusWidgetIntent.swift
//  Backup Status Widget
//
//  Created by Niels Mouthaan on 20/11/2023.
//

import WidgetKit
import AppIntents

struct BackupDiskStatusWidgetIntent: WidgetConfigurationIntent {
    
    static var title: LocalizedStringResource = "Backup Disk"
    static var description = IntentDescription("View when Time Machine made backups to a selected Backup Disk.")

    @Parameter(title: "Backup Disk") var destination: Preferences.Destination?
}
