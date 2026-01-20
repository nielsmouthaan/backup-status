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
    
    private var preferenceFile: PreferencesFile?
    private var window: NSWindow?
    
    private var isRunningPreviews: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if isRunningPreviews {
            return
        }
        preferenceFile = PreferencesFile()
        if !launchedAsLogInItem {
            showWindow()
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows: Bool) -> Bool {
        if !hasVisibleWindows {
            showWindow()
        }
        preferenceFile?.updateAccess()
        return true
    }
    
    private func showWindow() {
        guard let preferenceFile else {
            return
        }
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
        if let preferenceFile, (!preferenceFile.hasAccess || !StartAtLaunch().enabled) {
            NSApplication.shared.terminate(self)
        }
    }
}
