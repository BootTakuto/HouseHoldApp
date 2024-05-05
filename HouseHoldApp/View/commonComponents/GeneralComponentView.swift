//
//  GeneralComponentView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/10.
//

import SwiftUI
import UIKit

class GeneralComponentView {
    @ViewBuilder
    func GlassBlur(effect: UIBlurEffect.Style, radius: CGFloat) -> some View {
        ZStack {
            UIGlassCard(effect: effect)
                .clipShape(RoundedRectangle(cornerRadius: radius))
        }
    }
    
    @ViewBuilder
    func GradientCard(colors: [Color], radius: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(
                    LinearGradient(colors: [colors[0],
                                            colors[1]],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
    }
    
    @ViewBuilder
    func ButtonGradientCircle(colors: [Color]) -> some View {
        ZStack {
            Circle()
                .fill(
                    .linearGradient(colors: [colors[0], colors[1]],
                                    startPoint: .topLeading, endPoint: .bottomTrailing)
                )
        }
    }
    
    @ViewBuilder
    func RoundedIcon(radius: CGFloat, color: Color, image: String, text: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(color)
            VStack {
                Image(systemName: image)
                    .foregroundStyle(.white)
                Text(text)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
    }
    
    func Border() -> some View {
        Rectangle().frame(height: 1)
    }
    
    func Bar() -> some View {
        Rectangle().frame(width: 1)
    }
    
    func RegistButton(colors: [Color], isDisable: Bool,
                      w: CGFloat, h: CGFloat, radius: CGFloat) -> some View {
        ZStack {
            if isDisable {
                GlassBlur(effect: .systemUltraThinMaterial, radius: 15)
            } else {
                GradientCard(colors: colors, radius: radius)
            }
        }
    }
    
    
}


#Preview {
    SampleView()
}
