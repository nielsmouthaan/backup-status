//
//  AppDelegate.swift
//  BackupStatus
//
//  Created by Niels Mouthaan on 23/11/2023.
//

import Cocoa
import SwiftUI

@main
@MainActor
class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    var preferenceFile = PreferencesFile()
    var window: NSWindow?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if !launchedAsLogInItem {
            showWindow()
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            showWindow()
        }
        preferenceFile.updateAccess()
        return true
    }
    
    private func showWindow() {
        if window == nil {
            window = NSWindow(contentRect: .zero, styleMask: [.titled, .closable, .miniaturizable], backing: .buffered, defer: false)
            window!.isReleasedWhenClosed = false
            window!.titleVisibility = .hidden
            window!.isMovableByWindowBackground = true
            window!.titlebarAppearsTransparent = true
            window!.backgroundColor = .textBackgroundColor
            window!.title = "Backup Status"
            window!.contentView = NSHostingView(rootView: AppView(preferenceFile: preferenceFile))
            window!.delegate = self
            window!.setContentSize(window!.contentView!.fittingSize)
        }
        window!.center()
        window!.makeKeyAndOrderFront(nil)
    }
    
    private var launchedAsLogInItem: Bool {
        guard let event = NSAppleEventManager.shared().currentAppleEvent else { return false }
        return event.eventID == kAEOpenApplication && event.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
    }
    
    func windowWillClose(_ notification: Notification) {
        if !preferenceFile.hasAccess || !StartAtLaunch().enabled {
            NSApplication.shared.terminate(self)
        }
    }
}
