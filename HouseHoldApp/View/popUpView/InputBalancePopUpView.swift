//
//  InputBalanceAlertView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/07/31.
//

import SwiftUI

struct InputBalancePopUpView: View {
    var accentColors: [Color]
    @Binding var popUpFlg: Bool
    @Binding var balNm: String
    @Binding var colorIndex: Int
    @FocusState var addBalNmFocused
    
    // 汎用ビュー
    let generalView = GeneralComponentView()
    // service
    let balanceService = BalanceService()
    // 実行処理
    var action: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            InputBalanceAlert()
        }.ignoresSafeArea()
    }
    
    // 残高追加アラート
    @ViewBuilder
    func InputBalanceAlert() -> some View {
        let rectWidth: CGFloat = 300
        let rectHeight: CGFloat = 200
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack {
                VStack {
                    Text("残高登録")
                        .fontWeight(.bold)
                    HStack(spacing: 0) {
                        Text("残高名(必須)")
                            .font(.footnote)
                            .frame(width: rectWidth / 4, alignment: .leading)
                        TextField("銀行名、ポイント名など", text: $balNm)
                            .focused($addBalNmFocused)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 5)
                            .background(Color(uiColor: .systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .font(.footnote)
                            .frame(width: rectWidth * (3 / 4))
                    }
//                    HStack(spacing: 0) {
//                        Text("金額初期設定")
//                            .font(.caption2.bold())
//                            .frame(width: rectWidth / 3, alignment: .leading)
//                        TextField("", text: $initBalAmount)
//                            .focused($addBalInitAmountFocused)
//                            .padding(5)
//                            .background(Color(uiColor: .systemGray5))
//                            .clipShape(RoundedRectangle(cornerRadius: 5))
//                            .multilineTextAlignment(.trailing)
//                            .font(.caption.bold())
//                            .frame(width: rectWidth * (2 / 3))
//                            .keyboardType(.numberPad)
//                    }
                    HStack(spacing: 0) {
                        Text("識別カラー")
                            .font(.footnote)
                            .frame(width: rectWidth / 4, alignment: .leading)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(ColorAndImage.colors.indices, id: \.self) {index in
                                    let color = ColorAndImage.colors[index]
                                    Button(action: {
                                        self.colorIndex = index
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(color)
                                                .frame(width: 30)
                                            if self.colorIndex == index {
                                                Circle()
                                                    .stroke(lineWidth: 3)
                                                    .fill(.changeable)
                                                    .frame(width: 20)
                                            }
                                        }
                                    }
                                }
                            }
                        }.frame(width: rectWidth * (3 / 4))
                            .scrollIndicators(.hidden)
                    }
                }.frame(height: rectHeight - 40)
                    .padding(.horizontal, 15)
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            self.popUpFlg = false
                            self.balNm = ""
//                            self.initBalAmount = "0"
                            self.colorIndex = 0
                        }
                    }) {
                        ZStack {
                            accentColors.last ?? .black
                            Text("閉じる")
                        }
                    }
                    generalView.Bar()
                        .foregroundStyle(.changeable)
                    Button(action: {
                        withAnimation {
//                            balanceService.registBalance(balanceNm: balNm,
//                                                         balAmt: Int(initBalAmount) ?? 0,
//                                                         colorIndex: colorIndex)
                            action()
                            self.popUpFlg = false
                            self.balNm = ""
//                            self.initBalAmount = "0"
                            self.colorIndex = 0
                        }
                    }) {
                        ZStack {
                            accentColors.last ?? .black
                            Text("保存")
                        }
                    }
                }.frame(height: 40)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }.foregroundStyle(Color.changeableText)
        }.clipShape(RoundedRectangle(cornerRadius: 10))
//            .offset(y: addBalNmFocused ? -40 : addBalInitAmountFocused ? -30 : 0)
            .offset(y: addBalNmFocused ? -40 : 0)
            .animation(.linear, value: addBalNmFocused)
//            .animation(.linear, value: addBalInitAmountFocused)
            .frame(width: rectWidth, height: rectHeight)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Button(action: {
                            if addBalNmFocused {
                                self.balNm = ""
                                self.addBalNmFocused = false
                            }
//                            else if addBalInitAmountFocused {
//                                self.initBalAmount = "0"
//                                self.addBalInitAmountFocused = false
//                            }
                        }) {
                            Text("キャンセル")
                        }
                        Spacer()
                        Button(action: {
                            if addBalNmFocused {
                                self.addBalNmFocused = false
                            }
//                            else if addBalInitAmountFocused {
//                                if self.initBalAmount == "" {
//                                    self.initBalAmount = "0"
//                                }
//                                self.addBalInitAmountFocused = false
//                            }
                        }) {
                            Text("完了")
                        }
                    }
                }
            }
//            .onChange(of: addBalInitAmountFocused) {
//                if addBalInitAmountFocused && self.initBalAmount == "0" {
//                    self.initBalAmount = ""
//                }
//            }
    }
}

#Preview {
    @State var popUpFlg = false
    @State var balNm = ""
    @State var colorIndex = 0
    return InputBalancePopUpView(accentColors: [.blue, .mint],
                                 popUpFlg: $popUpFlg,
                                 balNm: $balNm,
                                 colorIndex: $colorIndex) {
        
    }
}
