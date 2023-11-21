//
//  Preferences.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 21/11/2023.
//

import Foundation
import OSLog

struct Preferences {
    
    struct Destination {
        
        enum Result {
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
    
    var destinations: [Destination] = []
    
    init?(url: URL) {
        if url.startAccessingSecurityScopedResource() {
            do {
                let data = try Data(contentsOf: url)
                guard let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
                    Logger.main.error("Failed serializing preferences file")
                    return nil
                }
                guard let destinationsData = plist["Destinations"] as? [[String: Any]] else {
                    Logger.main.error("Missing or invalid Destinations attribute in preferences file")
                    return nil
                }
                self.destinations = destinationsData.compactMap { Destination($0) }
            } catch {
                Logger.main.error("Failed reading content from preferences file: \(error.localizedDescription)")
                return nil
            }
            url.stopAccessingSecurityScopedResource()
        } else {
            Logger.main.error("Failed accessing preferences file")
            return nil
        }
    }
}
