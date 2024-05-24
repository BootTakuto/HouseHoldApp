//
//  ContentTabBar.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/01/18.
//

import SwiftUI
import RealmSwift

struct ContentTabBar: View {
    var accentColors: [Color]
    @Binding var selectedContent: Int
    @State var registIncConsFlg = false
    @ObservedResults(BalanceModel.self) var balanceResults
    let screen = UIScreen.main.bounds
    let generalView = GeneralComponentView()
    var body: some View {
        // タブのボタン
            VStack(spacing: 0) {
                ZStack(alignment: .top) {
                    Color.changeableDefault
                        .clipShape(
                            TabCurve(height: screen.height / 9)
                        )
                    HStack(spacing: 0) {
                        TabBarButton(image: "house",
                                     text: "ホーム",
                                     accentColors: accentColors,
                                     contentIndex: 0,
                                     selectedContent: $selectedContent)
                        TabBarButton(image: "yensign.square",
                                     text: "残　高",
                                     accentColors: accentColors,
                                     contentIndex: 1,
                                     selectedContent: $selectedContent)
                        GeometryReader { geom in
                            VStack(spacing: 0) {
                                Button(action: {
                                    registIncConsFlg = true
                                }) {
                                    ZStack {
                                        generalView.ButtonGradientCircle(colors: accentColors)
                                            .shadow(color: .changeableShadow, radius: 3)
                                        Image(systemName: "square.and.pencil")
                                            .foregroundStyle(.white)
                                            .font(.system(size: screen.width / 20, weight: .semibold))
                                    }
                                }.offset(y: -3)
                                Text("入　力")
                                    .font(.caption2.bold())
                                    .foregroundStyle(Color.changeableText)
                            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        }.frame(height: screen.height / 12)
                        TabBarButton(image: "arrow.down.left.arrow.up.right",
                                     text: "入出金",
                                     accentColors: accentColors,
                                     contentIndex: 2,
                                     selectedContent: $selectedContent)
                        TabBarButton(image: "ellipsis",
                                     text: "その他",
                                     accentColors: accentColors,
                                     contentIndex: 3,
                                     selectedContent: $selectedContent)
                    }.padding(.top, 10)
                }.frame(height: screen.height / 9)
                .ignoresSafeArea()
        }.compositingGroup()
            .shadow(color: .changeableShadow, radius: 3)
            .fullScreenCover(isPresented: $registIncConsFlg) {
                RegistIncConsFormView(registIncConsFlg: $registIncConsFlg,
                                      accentColors: accentColors,
                                      isEdit: false)
            }
    }
}

// タブボタン
struct TabBarButton: View {
    var image: String
    var text: String
    var accentColors: [Color]
    var contentIndex: Int
    let screen = UIScreen.main.bounds
    let generalView = GeneralComponentView()
    @Binding var selectedContent: Int
    var body: some View {
        GeometryReader { geometory in
            Button(action: {
                withAnimation(.interpolatingSpring(
                    mass: 0.5,
                    stiffness: 250.0,
                    damping: 20.0,
                    initialVelocity: 2.0
                  )) {
                    self.selectedContent = contentIndex
                }
            }) {
                VStack(spacing: 2) {
                    ZStack {
                        if selectedContent == contentIndex {
                            generalView.ButtonGradientCircle(colors: accentColors)
                                .shadow(color: .changeableShadow, radius: 3)
                                .frame(width: screen.width / 12)
                        }
                        Image(systemName: image)
                            .font(.system(size: screen.width / 25, weight: .semibold))
                            .foregroundStyle(selectedContent == contentIndex ? Color.white : Color.gray)
                    }
                    Text(text)
                        .foregroundStyle(selectedContent == contentIndex ?
                            .changeableText : Color.clear)
                        .font(.caption2.bold())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            // タップ時にリフトされるアニメーション
            .offset(y: selectedContent == contentIndex ? -5 : 0)
        }
        .frame(height: screen.height / 20)
    }
}

#Preview {
    return ContentView()
}
