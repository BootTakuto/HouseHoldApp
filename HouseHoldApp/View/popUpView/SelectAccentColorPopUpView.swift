//
//  InputAccentColorPopUpView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/08/08.
//

import SwiftUI

struct SelectAccentColorPopUpView: View {
    @State var accentColors: [Color]
    @Binding var popUpFlg: Bool
    @AppStorage("ACCENT_COLORS_INDEX") var accentColorsIndex = 0
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            AccentColorAlert()
        }.ignoresSafeArea()
    }
    
    @ViewBuilder
    func AccentColorAlert() -> some View {
        let rectWidth: CGFloat = 250
        let rectHeight: CGFloat = 250
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack {
                Text("テーマカラー")
                    .foregroundStyle(Color.changeableText)
                    .fontWeight(.bold)
                    .padding(.top, 10)
                ScrollView {
                    VStack {
                        ForEach(0..<4, id: \.self) { row in
                            HStack(spacing: 15) {
                                ForEach(0..<3, id: \.self) {col in
                                    let index = col + (row * 3)
                                    if GradientAccentcColors.gradients.count > index {
                                        Button(action: {
                                            accentColorsIndex = index
                                            accentColors = GradientAccentcColors.gradients[index]
                                        }) {
                                            let accentColors = GradientAccentcColors.gradients[index]
                                            Circle()
                                                .fill(.linearGradient(colors: accentColors,
                                                                      startPoint: .topLeading,
                                                                      endPoint: .topTrailing))
                                                .frame(width: 50, height: 50)
                                                .overlay(
                                                    Circle()
                                                        .stroke(lineWidth: 5)
                                                        .fill(accentColorsIndex == index ? .white : .clear)
                                                        .frame(width: 30, height: 30)
                                                )
                                        }
                                    } else {
                                        Color.clear
                                            .frame(width: 50, height: 50)
                                    }
                                }
                            }
                        }
                    }
                }.scrollIndicators(.hidden)
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            self.popUpFlg = false
                        }
                    }) {
                        ZStack {
                            accentColors.last ?? .black
                            Text("完了")
                        }
                    }
                }.frame(height: 40)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }
        }.frame(width: rectWidth, height: rectHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    @State var popUpFlg = false
    return SelectAccentColorPopUpView(accentColors: [.blue, .mint],
                                      popUpFlg: $popUpFlg)
}
