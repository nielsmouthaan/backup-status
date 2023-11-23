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
    
    @Published var url: URL? {
        didSet {
            if url != nil {
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
                url = try URL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
            } catch {
                Preferences.clear()
                Logger.app.error("Unable to resolve bookmark: \(error)")
            }
        } else {
            Logger.app.info("Bookmark data not available in user defaults")
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
                if Preferences(url: url) != nil {
                    if self.bookmark(url: url) {
                        self.url = url
                    }
                } else {
                    let alert = NSAlert()
                    alert.messageText = "Incorrect file"
                    alert.informativeText = "Select \(URL.preferencesFile.lastPathComponent) from the displayed directory."
                    alert.alertStyle = .warning
                    alert.addButton(withTitle: "OK")
                    alert.runModal()
                }
            } else {
                Logger.app.warning("Preferences file was not selected")
            }
        })
    }
    
    private func bookmark(url: URL) -> Bool {
        do {
            let data = try url.bookmarkData(options: [.withSecurityScope, .securityScopeAllowOnlyReadAccess], includingResourceValuesForKeys: nil, relativeTo: nil)
            UserDefaults.shared.set(data, forKey: .bookmarkDataKey)
            return true
        } catch {
            Logger.app.error("Unable to bookmark URL: \(error)")
            Preferences.clear()
            return false
        }
    }
    
    private func startObservingForChanges() {
        guard let url else {
            fatalError("Preferences file is not accessible")
        }
        var context = FSEventStreamContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        stream = FSEventStreamCreate(
            nil,
            eventCallback,
            &context,
            [url.path] as CFArray,
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
            process()
        }
    }
    
    private let eventCallback: FSEventStreamCallback = { (stream, contextInfo, numEvents, eventPaths, eventFlags, eventIds) in
        guard let paths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String] else {
            fatalError("Failed parsing paths")
        }
        if !paths.filter({ $0 == URL.preferencesFile.path }).isEmpty {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .fileChangedNotification, object: nil)
            }
        }
    }
    
    func process() {
        guard let url else {
            fatalError("Preferences file is not accessible")
        }
        guard let preferences = Preferences(url: url) else {
            Preferences.clear()
            return
        }
        if !preferences.store() {
            Preferences.clear()
        }
    }
}
