//
//  TabCurve.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/01/20.
//

import SwiftUI

struct TabCurve: Shape {
    var height: CGFloat
    func path(in rect: CGRect) -> Path {
        return Path { path in
            let y: CGFloat = 12
            let mid = rect.width / 2
            path.move(to: CGPoint(x: mid - 40, y: y))
            
            let to1 = CGPoint(x: mid, y: 0)
            let ctrl1 = CGPoint(x: mid - 22, y: y)
            let ctrl2 = CGPoint(x: mid - 22, y: 0)
            
            let to2 = CGPoint(x: mid + 40, y: y)
            let ctrl3 = CGPoint(x: mid + 22, y: 0)
            let ctrl4 = CGPoint(x: mid + 22, y: y)
            
            path.addCurve(to: to1, control1: ctrl1, control2: ctrl2)
            path.addCurve(to: to2, control1: ctrl3, control2: ctrl4)
            path.addArc(center: CGPoint(x: 20, y: y + 20), radius: 20,
                        startAngle: Angle(degrees: 270), endAngle: Angle(degrees: 180), clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: height))
            path.addLine(to: CGPoint(x: rect.width, y: height))
            path.addLine(to: CGPoint(x: rect.width, y: y + 20))
            path.addLine(to: CGPoint(x: rect.width - 20, y: y))
            path.addArc(center: CGPoint(x: rect.width - 20, y: y + 20), radius: 20,
                        startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 270), clockwise: true)
        }
    }
}

#Preview {
    
    TabCurve(height: 100)
}
