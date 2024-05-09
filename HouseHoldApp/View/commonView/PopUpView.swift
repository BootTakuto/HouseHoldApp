//
//  PopUpView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/05/05.
//

import SwiftUI

struct PopUpView: View {
    var accentColors: [Color]
    @Binding var popUpFlg: Bool
    /* 残高登録情報*/
    @State var balanceNm = ""
    @State var colorIndex = 0
    // view完ｒ年ｍ
    let generalView = GeneralComponentView()
    var body: some View {
        GeometryReader {
            let size = $0.size
            ZStack {
            }
        }.ignoresSafeArea()
    }
    
    @ViewBuilder
    func SuccessPopUp(size: CGSize) -> some View {
        ZStack {
            Color.changeable
            VStack(spacing: 5) {
                Image(systemName: "checkmark.circle")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.green)
                Text("登録完了")
                    .foregroundStyle(Color.changeableText)
                    .fontWeight(.bold)
            }
        }.clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    @State var popUpFlg = false
    return PopUpView(accentColors: [.purple, .indigo],
                     popUpFlg: $popUpFlg)
}
