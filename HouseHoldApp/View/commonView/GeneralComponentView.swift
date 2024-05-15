//
//  GeneralComponentView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/10.
//

import SwiftUI
import UIKit

class GeneralComponentView {
    /* すりガラス四角形 */
    @ViewBuilder
    func GlassBlur(effect: UIBlurEffect.Style, radius: CGFloat) -> some View {
        UIGlassCard(effect: effect)
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
    
    /** グラデーション四角形  */
    @ViewBuilder
    func GradientCard(colors: [Color], radius: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(
                LinearGradient(colors: [colors[0],
                                        colors[1]],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
            )
    }
    
    /** グラデーション円 */
    @ViewBuilder
    func ButtonGradientCircle(colors: [Color]) -> some View {
        Circle()
            .fill(
                .linearGradient(colors: [colors[0], colors[1]],
                                startPoint: .topLeading, endPoint: .bottomTrailing)
            )
    }
    
    /** アイコン */
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
    
    /** ボーダー(横線) */
    func Border() -> some View {
        Rectangle().frame(height: 1)
    }
    
    /** ボーダー(縦線) */
    func Bar() -> some View {
        Rectangle().frame(width: 1)
    }
    
    /** 登録ボタン */
    func registButton(colors: [Color], radius: CGFloat,  isDisAble: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                if isDisAble {
                    GlassBlur(effect: .systemUltraThinMaterial, radius: radius)
                } else {
                    GradientCard(colors: colors, radius: radius)
                }
                Text(LabelsModel.registLabel)
                    .font(.caption.bold())
                    .foregroundStyle(isDisAble ? Color.changeableText : Color.white)
            }
        }.padding(.vertical, 10)
            .padding(.horizontal, 20)
            .disabled(isDisAble)
    }
    
    /** すりガラス円ボタン */
    func glassCircleButton(imageColor: Color, imageNm: String,  action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                UIGlassCard(effect: .systemUltraThinMaterial)
                    .clipShape(Circle())
                Image(systemName: imageNm)
                    .fontWeight(.bold)
                    .foregroundStyle(imageColor)
            }
        }
    }
    
    func glassTextRounedButton(color: Color, text: String, imageNm: String, radius: CGFloat ,action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                GlassBlur(effect: .systemUltraThinMaterial, radius: radius)
                HStack {
                    Text(text)
                    if imageNm != "" {
                        Image(systemName: imageNm)
                    }
                }.font(.caption.bold())
                    .foregroundStyle(color)
            }
        }
    }
}

#Preview {
    ContentView()
}
