//
//  DeletePopUpView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/07/30.
//

import SwiftUI

struct DeletePopUpView: View {
    var accentColors: [Color]
    @Binding var popUpFlg: Bool
    // 表示文言
    var title: String
    var explain: String
    // 汎用ビュー
    let generalView = GeneralComponentView()
    // 実行処理
    var action: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            DeleteAlert()
        }.ignoresSafeArea()
    }
    
    @ViewBuilder
    func DeleteAlert() -> some View {
        let rectWidth: CGFloat = 300
        let rectHeight: CGFloat = 150
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack {
                VStack {
                    Text("⚠️" + title)
                        .fontWeight(.medium)
                    Text(explain)
                        .font(.caption)
                        .fontWeight(.medium)
                }.frame(height: rectHeight - 40)
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            self.popUpFlg = false
                        }
                    }) {
                        ZStack {
                            accentColors.last ?? .black
                            Text("キャンセル")
                        }
                    }
                    generalView.Bar()
                        .foregroundStyle(.changeable)
                    Button(action: {
                        withAnimation {
                            action()
                            self.popUpFlg = false
                        }
                    }) {
                        ZStack {
                            Color.red
                            Text("削除")
                        }
                    }
                }.frame(height: 40)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }.foregroundStyle(Color.changeableText)
        }.frame(width: rectWidth, height: rectHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    @State var popUpFlg = false
    return DeletePopUpView(accentColors: [.blue, .purple],
                           popUpFlg: $popUpFlg,
                           title: "項目の削除",
                           explain: "項目を削除します。\nよろしいですか") {
        print("aaaaa")
    }
}
