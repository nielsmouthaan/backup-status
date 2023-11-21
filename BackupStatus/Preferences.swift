//
//  Preferences.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 21/11/2023.
//

import Foundation
import OSLog
import WidgetKit

extension String {
    
    static let preferencesKey = "preferences"
    private static let statusKey = "status"
    static let widgetKind = "BackupStatusWidget"
}

struct Preferences: Codable {
    
    struct Destination: Codable {
        
        enum Result: Codable {
            case OK
            case Other
        }
        
        let isEncrypted: Bool?
        let isNetwork: Bool?
        let bytesAvailable: Int?
        let bytesUsed: Int?
        let volumeName: String?
        let snapshots: [Date]?
        let attempts: [Date]?
        let result: Result?
        
        fileprivate init(isEncrypted: Bool? = nil, isNetwork: Bool? = nil, bytesAvailable: Int? = nil, bytesUsed: Int? = nil, volumeName: String? = nil, snapshots: [Date]? = nil, attempts: [Date]? = nil, result: Preferences.Destination.Result? = nil) {
            self.isEncrypted = isEncrypted
            self.isNetwork = isNetwork
            self.bytesAvailable = bytesAvailable
            self.bytesUsed = bytesUsed
            self.volumeName = volumeName
            self.snapshots = snapshots
            self.attempts = attempts
            self.result = result
        }
        
        init(_ dictionary: [String: Any]) {
            self.isEncrypted = dictionary["LastKnownEncryptionState"] as? String == "Encrypted"
            self.isNetwork = dictionary["NetworkURL"] != nil
            self.bytesAvailable = dictionary["BytesAvailable"] as? Int
            self.bytesUsed = dictionary["BytesUsed"] as? Int
            self.volumeName = dictionary["LastKnownVolumeName"] as? String
            self.snapshots = dictionary["SnapshotDates"] as? [Date]
            self.attempts = dictionary["AttemptDates"] as? [Date]
            if let result = dictionary["RESULT"] as? Int {
                if result == 0 {
                    self.result = .OK
                } else {
                    self.result = .Other
                }
            } else {
                self.result = nil
            }
        }
    }
    
    var destinations: [Destination]?
    
    fileprivate init(destinations: [Preferences.Destination]? = nil) {
        self.destinations = destinations
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
                return try JSONDecoder().decode(Preferences.self, from: data)
            } catch {
                print("Failed loading preferences: \(error)")
            }
        }
        return nil
    }
    
    static func clear() {
        UserDefaults.shared.removeObject(forKey: .preferencesKey)
        WidgetCenter.shared.reloadTimelines(ofKind: .widgetKind)
    }
    
    static var demo: Preferences {
        let snapshots = [
            Date(timeIntervalSinceNow: -30 * 60),
            Date(timeIntervalSinceNow: -90 * 60),
            Date(timeIntervalSinceNow: -150 * 60),
        ]
        let attempts = [
            Date(timeIntervalSinceNow: -3 * 60),
            Date(timeIntervalSinceNow: -35 * 60),
            Date(timeIntervalSinceNow: -120 * 60),
            Date(timeIntervalSinceNow: -180 * 60),
        ]
        let destination = Destination(isEncrypted: true, isNetwork: false, bytesAvailable: 1311960657920, bytesUsed: 454036393984, volumeName: "Time Machine", snapshots: snapshots, attempts: attempts, result: .OK)
        return Preferences(destinations: [destination])
    }
}
