//
//  PreferencesFile.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 20/11/2023.
//

import Foundation
import OSLog
import AppKit
import UniformTypeIdentifiers

private extension UserDefaults {
    
    static let shared = UserDefaults(suiteName: "nl.nielsmouthaan.backup-status.shared")!
}

private extension NSNotification.Name {
    
    static let fileChangedNotification = NSNotification.Name("fileChanged")
}

extension URL {
    
    static let preferencesFile = URL(fileURLWithPath: "/Library/Preferences/com.apple.TimeMachine.plist")
}

private extension String {
    
    static let bookmarkDataKey = "bookmarkData"
}

class PreferencesFile: ObservableObject {
    
    private var stream: FSEventStreamRef?
    private var lastChange: Date?
    
    @Published var accessibleURL: URL? {
        didSet {
            if accessibleURL != nil {
                process()
                startObservingForChanges()
            } else {
                stopObservingForChanges()
            }
        }
    }
    
    init() {
        if let bookmarkData = UserDefaults.shared.data(forKey: .bookmarkDataKey) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleFileChangedNotification), name: .fileChangedNotification, object: nil)
    }
    
    deinit {
        stopObservingForChanges()
        NotificationCenter.default.removeObserver(self)
    }
    
    func grantAccess() {
        let panel = NSOpenPanel();
        panel.message = "Select \(URL.preferencesFile.lastPathComponent)"
        panel.canChooseDirectories = false;
        panel.canChooseFiles = true;
        panel.canCreateDirectories = false;
        panel.allowsMultipleSelection = false;
        panel.directoryURL = URL.preferencesFile.deletingLastPathComponent()
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [UTType(filenameExtension: "plist")!]
        panel.begin(completionHandler: { result in
            if result == .OK, let url = panel.url {
                if self.isValid() {
                    if self.bookmark(url: url) {
                        self.accessibleURL = url
                    }
                } else {
                    #warning("TODO: Show alert")
                }
            } else {
                Logger.main.warning("Preferences file was not selected")
            }
        })
    }
    
    private func bookmark(url: URL) -> Bool {
        do {
            let data = try url.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess], includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.shared.set(data, forKey: .bookmarkDataKey)
            return true
        } catch {
            Logger.main.error("Unable to bookmark URL: \(error)")
            return false
        }
    }
    
    private func startObservingForChanges() {
        guard let accessibleURL else {
            fatalError("Preferences file is not accessible")
        }
        var context = FSEventStreamContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        stream = FSEventStreamCreate(
            nil,
            eventCallback,
            &context,
            [accessibleURL.path] as CFArray,
            FSEventsGetCurrentEventId(),
            0,
            FSEventStreamCreateFlags(kFSEventStreamCreateFlagUseCFTypes | kFSEventStreamCreateFlagFileEvents)
        )
        FSEventStreamSetDispatchQueue(stream!, DispatchQueue(label: "Preferences file observer queue"))
        FSEventStreamStart(stream!)
    }
    
    private func stopObservingForChanges() {
        if let stream {
            FSEventStreamStop(stream)
            FSEventStreamInvalidate(stream)
            FSEventStreamRelease(stream)
        }
    }
    
    @objc private func handleFileChangedNotification() {
        if lastChange == nil { // Upon observing a change is immediately observed, which should be ignored.
            lastChange = Date()
        } else if Date().timeIntervalSince(lastChange!) > 1 { // Prevents multiple triggers caused by the same change.
            lastChange = Date()
            Logger.main.info("Preferences file has changed")
            process()
        }
    }
    
    private let eventCallback: FSEventStreamCallback = { (stream, contextInfo, numEvents, eventPaths, eventFlags, eventIds) in
        guard let paths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] else {
            fatalError("Error while parsing paths")
        }
        if !paths.filter({ $0 == URL.preferencesFile.path }).isEmpty {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .fileChangedNotification, object: nil)
            }
        }
    }
    
    private func isValid() -> Bool {
        guard let accessibleURL else {
            return false
        }
        return Preferences(url: accessibleURL) != nil
    }
    
    private func process() {
        guard let accessibleURL else {
            fatalError("Preferences file is not accessible")
        }
        guard let preferences = Preferences(url: accessibleURL) else {
            #warning("TODO: Store error so widget can display it")
            return
        }
        
        print(preferences)
    }
}
