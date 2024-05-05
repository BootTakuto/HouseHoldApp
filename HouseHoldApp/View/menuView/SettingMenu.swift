//
//  ReportView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2023/08/02.
//

import SwiftUI

struct SettingMenu: View {
    @AppStorage("ACCENT_COLORS_INDEX") var accentColorsIndex = 0
    var accentColors: [Color]
    let generalView = GeneralComponentView()
    let commonService = CommonService()
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                VStack(alignment: .leading) {
                    Text("アクセントカラー")
                        .foregroundStyle(Color.changeableText)
                        .font(.caption.bold())
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0) {
                            ForEach(GradientAccentcColors.gradients.indices, id:\.self) { index in
                                let gradient = GradientAccentcColors.gradients[index]
                                let isSelect = index == accentColorsIndex
                                Button(action: {
                                    withAnimation {
                                        accentColorsIndex = index
                                    }
                                }){
                                    generalView.GradientCard(colors: gradient, radius: 10)
                                        .padding(isSelect ? 2 : 5)
                                        .shadow(color: isSelect ? .changeableShadow : .clear, radius: 2)
                                }.frame(width: size.width / 5)
                            }
                        }
                    }.frame(height: 60)
                        .scrollIndicators(.hidden)
                }.padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    var accentColors = [Color.red, Color.green, Color.mint]
    return SettingMenu(accentColors: accentColors)
}
