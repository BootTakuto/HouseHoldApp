//
//  UIGlassCard.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/24.
//

import SwiftUI
import UIKit

struct UIGlassCard: UIViewRepresentable{
    var effect: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: effect))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    UIGlassCard(effect: .systemUltraThinMaterial)
}
