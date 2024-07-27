//
//  GeneralComponentView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/10.
//

import SwiftUI
import UIKit

class GeneralComponentView {
    /* すりガラス四角 */
    @ViewBuilder
    func GlassBlur(effect: UIBlurEffect.Style, radius: CGFloat) -> some View {
        UIGlassCard(effect: effect)
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
    
    /** グラデーション四角 */
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
    @ViewBuilder // 表示のみ
    func RoundedIcon(radius: CGFloat,
                     color: Color,
                     image: String,
                     text: String) -> some View {
        GeometryReader {
            let size = $0.size
            ZStack {
                RoundedRectangle(cornerRadius: radius)
                    .fill(color)
                VStack(spacing: 0) {
                    Image(systemName: image)
                        .frame(height: size.height / 2)
                        .scaledToFit()
                        .foregroundStyle(.white)
//                        .fontDesign(.rounded)
                    if text != "" {
                        Text(text)
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
            }
        }
    }
    @ViewBuilder // 選択によって表示を変更する
    func RoundedIcon(radius: CGFloat,
                     color: Color,
                     image: String,
                     text: String,
                     isSelected: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius)
                .fill(color)
                .opacity(isSelected ? 1 : 0.1)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                        .fill(color)
                        .opacity(isSelected ?  1 : 0.5)
                )
            VStack(spacing: 0) {
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .padding(.horizontal, 5)
                    .padding(.top, 8)
//                    .fontDesign(.rounded)
                Text(text)
                    .font(.caption.bold())
                    .padding(.horizontal, 2)
                    .padding(.vertical, 5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
            }.foregroundStyle(isSelected ? .white : color)
                .opacity(isSelected ?  1 : 0.5)
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
    func registButton(colors: [Color],
                      radius: CGFloat,
                      isDisAble: Bool,
                      action: @escaping () -> Void) -> some View {
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
    func glassCircleButton(imageColor: Color,
                           imageNm: String,
                           action: @escaping () -> Void) -> some View {
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
    
    func glassTextRounedButton(color: Color,
                               text: String,
                               imageNm: String,
                               radius: CGFloat,
                               action: @escaping () -> Void) -> some View {
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
    
    @ViewBuilder
    func menuIconButton(isColorCard: Bool,
                        accentColors: [Color],
                        iconNm: String,
                        imageNm: String,
                        action: @escaping () -> Void) -> some View {
        Button(action: action) {
            ZStack {
                if isColorCard {
                    GradientCard(colors: accentColors, radius: 10)
                        .frame(width: 120, height: 120)
                } else {
                    GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                        .frame(width: 120, height: 120)
                }
                VStack {
                    Image(systemName: imageNm)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .padding(5)
                    Text(iconNm)
                        .font(.headline)
                        .fontWeight(.medium)
                        .frame(width: 100)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }.foregroundStyle(isColorCard ? Color.white : .changeableText)
        }
    }
}

#Preview {
    ContentView()
}
