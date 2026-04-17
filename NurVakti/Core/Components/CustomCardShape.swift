//
//  CustomCardShape.swift
//  NurVakti
//
//  Created by Yakup Suda on 13.04.2026.
//

import SwiftUI
import UIKit

// MARK: - Reusable Card Shape (local for now)
 struct CustomCardShape: View {
    enum CutEdge {
        case top
        case bottom
    }

    let cutEdge: CutEdge
    var radius: CGFloat = 20
    var fillColor: Color = .white
    var inset: CGFloat = 0

    var body: some View {
        Self.shape(cutEdge: cutEdge, radius: radius)
            .fill(fillColor)
            .offset(y: cutEdge == .top ? inset : -inset)
    }

    static func shape(cutEdge: CutEdge, radius: CGFloat) -> RoundedCorner {
        RoundedCorner(
            radius: radius,
            corners: cutEdge == .top ? [.topLeft, .topRight] : [.bottomLeft, .bottomRight]
        )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
