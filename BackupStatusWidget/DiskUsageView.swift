//
//  DiskUsageView.swift
//  BackupStatus
//
//  Created by Niels Mouthaan on 22/11/2023.
//

import SwiftUI

struct DiskUsageView: View {
    
    private let size = 5.0
    
    let used: Int64
    let available: Int64
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: .infinity)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .foregroundColor(.primary.opacity(0.1))
                RoundedRectangle(cornerRadius: .infinity)
                    .frame(width: width(fullWidth: geometry.size.width), height: geometry.size.height)
                    .foregroundStyle(color)
            }
        }
        .frame(height: size)
        .padding(.bottom, 3)
    }
    
    private func width(fullWidth: CGFloat) -> CGFloat {
        let total = used + available
        guard total > 0 else {
            return 0
        }
        let width = CGFloat(CGFloat(used) / CGFloat(total)) * fullWidth
        return width > size ? width : size
    }
    
    private var color: Color {
        let total = used + available
        guard total > 0 else {
            return .primary
        }
        let usedPercentage = Double(used) / Double(total)
        if usedPercentage < 0.7 {
            return Color.green
        } else if usedPercentage < 0.9 {
            return Color.orange
        } else {
            return Color.red
        }
    }
}

#Preview("DiskUsageView") {
    DiskUsageView(used: 50, available: 100)
}
