//
//  StartAtLaunch.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 21/11/2023.
//

import Foundation
import ServiceManagement
import OSLog

class StartAtLaunch: ObservableObject {
    
    @Published var enabled: Bool {
       didSet {
           do {
               if enabled {
                   try SMAppService.mainApp.register()
               } else {
                   try SMAppService.mainApp.unregister()
               }
           } catch {
               Logger.app.error("Failed to \(self.enabled ? "enable" : "disable") start at launch: \(error)")
           }
       }
   }

   init() {
       self.enabled = SMAppService.mainApp.status == .enabled
   }
}
