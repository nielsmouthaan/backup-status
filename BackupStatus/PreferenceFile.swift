//
//  PreferenceFile.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 20/11/2023.
//

import Foundation
import OSLog
import AppKit
import UniformTypeIdentifiers

class PreferenceFile: ObservableObject {
    
    private let userDefaults = UserDefaults(suiteName: "nl.nielsmouthaan.backup-status.shared")!
    private let bookmarkDataKey = "bookmarkData"
    let path = URL(fileURLWithPath: "/Library/Preferences/com.apple.TimeMachine.plist")
    @Published var accessibleURL: URL?
    
    init() {
        if let bookmarkData = userDefaults.data(forKey: bookmarkDataKey) {
            do {
                var isStale = false // Seems to work better when ignored.
                accessibleURL = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
                Logger.main.info("Bookmark data resolved")
            } catch {
                Logger.main.error("Unable to resolve bookmark: \(error)")
            }
        } else {
            Logger.main.info("Bookmark data not available in user defaults")
        }
    }
    
    func grantAccess() {
        let panel = NSOpenPanel();
        panel.message = "Select \(path.lastPathComponent)"
        panel.canChooseDirectories = false;
        panel.canChooseFiles = true;
        panel.canCreateDirectories = false;
        panel.allowsMultipleSelection = false;
        panel.directoryURL = path.deletingLastPathComponent()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "plist")!]
        panel.begin(completionHandler: { result in
            if result == .OK, let url = panel.url {
                if self.bookmark(url: url) {
                    self.accessibleURL = url
                }
            } else {
                Logger.main.warning("File was not selected")
            }
        })
    }
    
    private func bookmark(url: URL) -> Bool {
        do {
            let data = try url.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess], includingResourceValuesForKeys: nil, relativeTo: nil)
            userDefaults.set(data, forKey: bookmarkDataKey)
            return true
        } catch {
            Logger.main.error("Unable to bookmark URL: \(error)")
            return false
        }
    }
}
