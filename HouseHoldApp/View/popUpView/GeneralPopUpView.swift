//
//  TextPopUpView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/07/31.
//

import SwiftUI

struct GeneralPopUpView<Content: View>: View {
    @Binding var popUpFlg: Bool
    @Environment(\.colorScheme) var colorScheme
    @ViewBuilder var content: Content
    let generalView = GeneralComponentView()
    var body: some View {
        var count = 2
        ZStack {
            Rectangle().fill(.black.opacity(0.25))
            TextAlert()
        }.ignoresSafeArea()
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    count -= 1
                    if count == 0 {
                        // 現在のカウントが0になったらtimerを終了させ、カントダウン終了状態に更新
                        timer.invalidate()
                        withAnimation {
                            self.popUpFlg = false
                        }
                    }
                }
            }.onTapGesture {
                withAnimation {
                    self.popUpFlg = false
                    print("genralPopUp")
                }
            }
    }
    
    @ViewBuilder
    func TextAlert() -> some View {
        ZStack {
            if self.colorScheme == .dark {
                generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
            } else {
                Color.white
            }
//            Color.changeable
//            VStack(spacing: 5) {
//                Image(systemName: imageNm)
//                    .font(.largeTitle)
//                    .fontWeight(.medium)
//                    .foregroundStyle(self.status == .success ? Color.green : Color.red)
//                Text(text)
//                    .foregroundStyle(Color.changeableText)
//                    .fontWeight(.bold)
//            }
            content
        }.clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(width: 200, height: 100)
            .shadow(radius: 10)
    }
}

#Preview {
    @State var popUpFlg = false
    return GeneralPopUpView(popUpFlg: $popUpFlg) {
        VStack(spacing: 5) {
            Image(systemName: "checkmark.circle")
                .font(.largeTitle)
                .fontWeight(.medium)
                .foregroundStyle(Color.green)
            Text("text")
                .foregroundStyle(Color.changeableText)
        }
    }
}
