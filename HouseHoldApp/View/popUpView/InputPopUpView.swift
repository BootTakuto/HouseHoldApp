//
//  InputPopUpView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/07/29.
//

import SwiftUI

struct InputPopUpView: View {
    @State var accentColors: [Color]
    @Binding var popUpFlg: Bool
    @Binding var inputText: String
//    var status: PopUpStatus
    /** 表示内容 */
    var title = ""
    var explain = ""
    var placeHolder = ""
    // 汎用ビュー
    let generalView = GeneralComponentView()
    // 実行関数
    var action: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            InputAlert()
        }.ignoresSafeArea()
    }
    
    @ViewBuilder
    func InputAlert() -> some View {
        let isWithoutExplain = explain.count == 0
        let rectHeight: CGFloat = isWithoutExplain ? 150 : 200
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack {
                Text(title)
                    .fontWeight(.bold)
                if !isWithoutExplain {
                    Text(explain)
                        .font(.caption)
                        .fontWeight(.bold)
                }
                TextField(placeHolder, text: $inputText)
                    .padding(10)
                    .background(Color(uiColor: .systemGray4))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .fontWeight(.medium)
                    .padding(.horizontal, 20)
                Spacer()
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            self.popUpFlg = false
                        }
                    }) {
                        ZStack {
                            Color.changeable
                            Text("キャンセル")
                                .foregroundStyle(Color.changeableText)
                        }
                    }
                    generalView.Bar()
                        .foregroundStyle(Color.clear)
                    Button(action: {
                        withAnimation {
                            action()
                            self.popUpFlg = false
                        }
                    }) {
                        ZStack {
                            Color.changeable
                            Text("保存")
                                .foregroundStyle(Color.changeableText)
                        }
                    }
                }.frame(height: 40)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }.foregroundStyle(Color.changeableText)
                .padding(.top, 20)
        }.frame(height: rectHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)
    }
}

#Preview {
    @State var popUpFlg = false
    @State var inputText = ""
    return InputPopUpView(accentColors: [.blue, .purple],
                          popUpFlg: $popUpFlg,
                          inputText: $inputText) {
        print("aaa")
    }
}
