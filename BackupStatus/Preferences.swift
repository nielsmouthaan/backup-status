//
//  Preferences.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 21/11/2023.
//

import Foundation
import OSLog
import WidgetKit
import AppIntents

extension String {
    
    static let preferencesKey = "preferences"
    private static let statusKey = "status"
    static let widgetKind = "BackupStatusWidget"
}

struct Preferences: Codable {
    
    struct DestinationQuery: EntityQuery {
        
        func entities(for identifiers: [Destination.ID]) async throws -> [Destination] {
            if let destinations = Preferences.load()?.destinations {
                return destinations.filter { identifiers.contains($0.id) }
            } else {
                return []
            }
        }
        
        func suggestedEntities() async throws -> [Destination] {
            return Preferences.load()?.destinations ?? []
        }
        
        func defaultResult() async -> Destination? {
            return Preferences.load()?.lastDestination
        }
    }
    
    struct Destination: Codable, AppEntity {
        
        static var defaultQuery = DestinationQuery()
        
        static var typeDisplayRepresentation: TypeDisplayRepresentation = "Backup Disk"
        
        var displayRepresentation: DisplayRepresentation {
            DisplayRepresentation(title: "\(volumeName)")
        }
        
        let id: String
        let isEncrypted: Bool
        let isNetwork: Bool
        let bytesAvailable: Int64
        let bytesUsed: Int64
        let volumeName: String
        let snapshots: [Date]
        
        fileprivate init(id: String, isEncrypted: Bool, isNetwork: Bool, bytesAvailable: Int64, bytesUsed: Int64, volumeName: String, snapshots: [Date]) {
            self.id = id
            self.isEncrypted = isEncrypted
            self.isNetwork = isNetwork
            self.bytesAvailable = bytesAvailable
            self.bytesUsed = bytesUsed
            self.volumeName = volumeName
            self.snapshots = snapshots
        }
        
        init(_ dictionary: [String: Any]) {
            self.id = dictionary["DestinationID"] as? String ?? ""
            self.isEncrypted = dictionary["LastKnownEncryptionState"] as? String == "Encrypted"
            self.isNetwork = dictionary["NetworkURL"] != nil
            self.bytesAvailable = dictionary["BytesAvailable"] as? Int64 ?? 0
            self.bytesUsed = dictionary["BytesUsed"] as? Int64 ?? 0
            self.volumeName = dictionary["LastKnownVolumeName"] as? String ?? ""
            self.snapshots = dictionary["SnapshotDates"] as? [Date] ?? []
        }
        
        var lastSnapshot: Date? {
            snapshots.max() ?? nil
        }
    }
    
    var destinations: [Destination]
    var lastDestination: Destination?
    
    fileprivate init(destinations: [Destination], lastDestination: Destination?) {
        self.destinations = destinations
        self.lastDestination = lastDestination
    }
    
    init?(url: URL) {
        if url.startAccessingSecurityScopedResource() {
            do {
                let data = try Data(contentsOf: url)
                guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
                    Logger.app.error("Failed serializing preferences file")
                    return nil
                }
                guard let destinationsData = plist["Destinations"] as? [[String: Any]] else {
                    Logger.app.error("Missing or invalid Destinations attribute in preferences file")
                    return nil
                }
                self.destinations = destinationsData.compactMap { Destination($0) }
                if let lastDestinationId = plist["LastDestinationID"] as? String {
                    self.lastDestination = self.destinations.filter { $0.id == lastDestinationId }.first
                }
            } catch {
                Logger.app.error("Failed reading content from preferences file: \(error)")
                return nil
            }
            url.stopAccessingSecurityScopedResource()
        } else {
            Logger.app.error("Failed accessing preferences file")
            return nil
        }
    }
    
    public func store() -> Bool {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.shared.set(data, forKey: .preferencesKey)
            WidgetCenter.shared.reloadTimelines(ofKind: .widgetKind)
            Logger.app.info("Preferences stored")
            return true
        } catch {
            Logger.app.error("Failed storing preferences: \(error)")
            return false
        }
    }
    
    static func load() -> Preferences? {
        if let data = UserDefaults.shared.data(forKey: .preferencesKey) {
            do {
                let preferences = try JSONDecoder().decode(Preferences.self, from: data)
                Logger.app.info("Preferences loaded")
                return preferences
            } catch {
                Logger.app.error("Failed loading preferences: \(error)")
            }
        } else {
            Logger.app.info("Preferences not available")
        }
        return nil
    }
    
    static func clear() {
        UserDefaults.shared.removeObject(forKey: .preferencesKey)
        WidgetCenter.shared.reloadTimelines(ofKind: .widgetKind)
    }
    
    static var demo: Preferences {
        var snapshots = [Date]()
        for i in 0..<20 {
            if let date = Calendar.current.date(byAdding: .hour, value: -4 * i, to: Date()) {
                snapshots.append(Calendar.current.date(byAdding: .second, value: Int.random(in: -10000..<10000), to: date)!)
            }
        }
        let destination = Destination(id: "0F051871-0C44-4856-83C6-4852661B2BF7", isEncrypted: true, isNetwork: false, bytesAvailable: 1311960657920, bytesUsed: 454036393984, volumeName: "Time Machine", snapshots: snapshots)
        return Preferences(destinations: [destination], lastDestination: destination)
    }
}
