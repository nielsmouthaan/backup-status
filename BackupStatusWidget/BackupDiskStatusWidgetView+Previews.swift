//
//  BackupDiskStatusWidgetView+Previews.swift
//  Backup Status
//
//  Created by Codex on 14/04/2026.
//

import SwiftUI
import WidgetKit

private enum BackupDiskStatusWidgetPreviewData {
    static let now = Date()

    static let healthy = destination(
        volumeName: "Time Machine",
        snapshots: snapshotDates(hoursAgo: [0, 4, 8, 12, 16, 20, 24, 28, 32]),
        isEncrypted: true,
        isNetwork: false
    )

    static let warning = destination(
        volumeName: "Archive Backup",
        snapshots: snapshotDates(hoursAgo: [30, 36, 42, 48]),
        isEncrypted: true,
        isNetwork: false
    )

    static let noBackups = destination(
        volumeName: "NAS Backup",
        snapshots: [],
        isEncrypted: false,
        isNetwork: true
    )

    static var notSetUpPreferences: Preferences? {
        nil
    }

    static var noBackupDiskPreferences: Preferences {
        preferences(lastDestination: nil, destinations: [healthy])
    }

    static var noBackupsPreferences: Preferences {
        preferences(lastDestination: noBackups)
    }

    static var healthyPreferences: Preferences {
        preferences(lastDestination: healthy)
    }

    static var warningPreferences: Preferences {
        preferences(lastDestination: warning)
    }

    private static func snapshotDates(hoursAgo offsets: [Int]) -> [Date] {
        offsets.compactMap { Calendar.current.date(byAdding: .hour, value: -$0, to: now) }
    }

    private static func preferences(lastDestination: Preferences.Destination?, destinations: [Preferences.Destination]? = nil) -> Preferences {
        var preferences = Preferences.demo
        preferences.destinations = destinations ?? lastDestination.map { [$0] }
        preferences.lastDestination = lastDestination
        return preferences
    }

    private static func destination(
        volumeName: String,
        snapshots: [Date],
        isEncrypted: Bool,
        isNetwork: Bool,
        bytesUsed: Int64 = 454_036_393_984,
        bytesAvailable: Int64 = 1_311_960_657_920
    ) -> Preferences.Destination {
        var dictionary: [String: Any] = [
            "DestinationID": volumeName,
            "LastKnownEncryptionState": isEncrypted ? "Encrypted" : "Not Encrypted",
            "BytesAvailable": bytesAvailable,
            "BytesUsed": bytesUsed,
            "LastKnownVolumeName": volumeName,
            "SnapshotDates": snapshots
        ]
        if isNetwork {
            dictionary["NetworkURL"] = "smb://backup.local/\(volumeName)"
        }
        return Preferences.Destination(dictionary)
    }
}

struct BackupDiskStatusWidgetViewPreviews: PreviewProvider {
    static var previews: some View {
        Group {
            preview(preferences: BackupDiskStatusWidgetPreviewData.healthyPreferences, family: .systemSmall)
                .previewDisplayName("Widget Small")
            preview(preferences: BackupDiskStatusWidgetPreviewData.healthyPreferences, family: .systemMedium)
                .previewDisplayName("Widget Medium")
            preview(preferences: BackupDiskStatusWidgetPreviewData.healthyPreferences, family: .systemLarge)
                .previewDisplayName("Widget Large")
            preview(preferences: BackupDiskStatusWidgetPreviewData.notSetUpPreferences, family: .systemSmall)
                .previewDisplayName("State Not Set Up")
            preview(preferences: BackupDiskStatusWidgetPreviewData.noBackupDiskPreferences, family: .systemMedium)
                .previewDisplayName("State No Backup Disk")
            preview(preferences: BackupDiskStatusWidgetPreviewData.noBackupsPreferences, family: .systemMedium)
                .previewDisplayName("State No Backups")
            preview(preferences: BackupDiskStatusWidgetPreviewData.warningPreferences, family: .systemMedium)
                .previewDisplayName("State Warning")
            preview(preferences: BackupDiskStatusWidgetPreviewData.healthyPreferences, family: .systemMedium)
                .environment(\.widgetRenderingMode, .fullColor)
                .previewDisplayName("Mode Full Color")
            preview(preferences: BackupDiskStatusWidgetPreviewData.healthyPreferences, family: .systemMedium)
                .environment(\.widgetRenderingMode, .accented)
                .previewDisplayName("Mode Accented")
            preview(preferences: BackupDiskStatusWidgetPreviewData.healthyPreferences, family: .systemMedium)
                .environment(\.widgetRenderingMode, .vibrant)
                .previewDisplayName("Mode Vibrant")
        }
    }

    private static func preview(preferences: Preferences?, family: WidgetFamily) -> some View {
        VStack {
            BackupDiskStatusWidgetView(
                preferences: preferences,
                widgetFamilyOverride: family
            )
            .padding()
        }
        .frame(width: previewSize(for: family).width, height: previewSize(for: family).height)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .padding()
    }

    private static func previewSize(for family: WidgetFamily) -> CGSize {
        switch family {
        case .systemSmall:
            CGSize(width: 165, height: 165)
        case .systemMedium:
            CGSize(width: 345, height: 165)
        case .systemLarge:
            CGSize(width: 345, height: 345)
        default:
            CGSize(width: 345, height: 165)
        }
    }
}
