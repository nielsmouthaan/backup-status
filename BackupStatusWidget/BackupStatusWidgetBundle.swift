//
//  BackupStatusWidgetBundle.swift
//  Backup Status Widget
//
//  Created by Niels Mouthaan on 20/11/2023.
//

import WidgetKit
import SwiftUI

@main
struct BackupStatusWidgetBundle: WidgetBundle {
    var body: some Widget {
        BackupDiskStatusWidget()
    }
}
