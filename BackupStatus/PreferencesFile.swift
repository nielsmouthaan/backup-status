//
//  PreferencesFile.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 20/11/2023.
//

import Foundation
import OSLog
import PermissionsKit

private extension NSNotification.Name {
    
    static let fileChangedNotification = NSNotification.Name("fileChanged")
}

extension URL {
    
    static let preferencesFile = URL(fileURLWithPath: "/Library/Preferences/com.apple.TimeMachine.plist")
}

class PreferencesFile: ObservableObject {
    
    init(demo: Bool = false) {
        self.demo = demo
        if !self.demo {
            updateAccess()
            NotificationCenter.default.addObserver(self, selector: #selector(handleFileChangedNotification), name: .fileChangedNotification, object: nil)
        }
    }
    
    private var stream: FSEventStreamRef?
    private var lastChange: Date?
    private let url = URL.preferencesFile
    var demo = false
    
    @Published private(set) var hasAccess = false
    
    deinit {
        stopObservingForChanges()
        NotificationCenter.default.removeObserver(self)
    }
    
    private func startObservingForChanges() {
        stopObservingForChanges()
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
        if demo {
            return
        }
        guard let preferences = Preferences(url: url) else {
            Preferences.clear()
            return
        }
        if preferences.store() {
            return
        }
        Preferences.clear()
        return
    }
    
    func updateAccess() {
        if demo {
            return
        }
        let status = PermissionsKit.authorizationStatus(for: .fullDiskAccess)
        let accessGranted = status == .authorized
        hasAccess = accessGranted
        if accessGranted {
            process()
            startObservingForChanges()
        } else {
            Preferences.clear()
            stopObservingForChanges()
        }
    }
}
