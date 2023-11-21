//
//  WidgetView.swift
//  Backup Status
//
//  Created by Niels Mouthaan on 21/11/2023.
//

import SwiftUI

struct WidgetView: View {
    
    @State var preferences: Preferences?
    
    var body: some View {
        VStack {
            if let preferences {
                Text("Last back-up")
                if let lastBackup = preferences.lastBackup {
                    Text(lastBackup, style: .relative)
                } else {
                    Text("No backup")
                }
            } else {
                VStack {
                    Text("Not Configured")
                        .font(.title3)
                        .bold()
                        .padding(.bottom, 5)
                    Text("Run the app **Backup Status** to configure this widget.")
                }
                .multilineTextAlignment(.center)
            }
        }
    }
}

extension Preferences {
    
    var lastBackup: Date? {
        return destinations?.compactMap { $0.snapshots?.max() }.max() ?? nil
    }
}

#Preview("Not Configured") {
    Group {
        VStack {
            Group {
                WidgetView(preferences: nil)
                    .frame(width: 165, height: 165)
                WidgetView(preferences: nil)
                    .frame(width: 345, height: 165)
                WidgetView(preferences: nil)
                    .frame(width: 345, height: 345)
            }
            .padding()
            .background(.white)
            .cornerRadius(25)
        }
        .padding()
    }
}

#Preview("Preferences") {
    Group {
        VStack {
            Group {
                WidgetView(preferences: Preferences.demo)
                    .frame(width: 165, height: 165)
                WidgetView(preferences: Preferences.demo)
                    .frame(width: 345, height: 165)
                WidgetView(preferences: Preferences.demo)
                    .frame(width: 345, height: 345)
            }
            .padding()
            .background(.white)
            .cornerRadius(25)
        }
        .padding()
    }
}
