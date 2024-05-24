//
//  PopUpView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/05/05.
//

import SwiftUI

struct PopUpView: View {
    /** 共通 */
    var accentColors: [Color]
    @Binding var popUpFlg: Bool
   
    var status: PopUpStatus
    /** 残高登録アラート情報(.addBal) */
    @FocusState var addBalNmFocused
    @FocusState var addBalInitAmountFocused
    @State var balNm = ""
    @State var initBalAmount = "0"
    @State var colorIndex = 0
    @State var balKey = ""
    /** 成功・失敗アラート(.sucess, .fail) */
    @State var text = ""
    @State var imageNm = ""
    
    // service
    let balanceService = BalanceService()
    // 汎用ビュー
    let generalView = GeneralComponentView()
    var body: some View {
        ZStack {
            Color.black.opacity(0.25)
            switch status {
            case .addBalance:
                addBalanceFormAlert()
            case .editBalance:
                editBalanceFormAlert()
            case .deleteBalance:
                deleteBalanceAlert()
            case .success:
                SuccessFailedPopUp()
            case .failed:
                SuccessFailedPopUp()
            }
        }.ignoresSafeArea()
            .onTapGesture {
                if status == .success || status == .failed {
                    withAnimation {
                        self.popUpFlg = false
                    }
                }
            }
    }
    
    // 残高追加アラート
    @ViewBuilder
    func addBalanceFormAlert() -> some View {
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
                            .font(.caption2.bold())
                            .frame(width: rectWidth / 3, alignment: .leading)
                        TextField("銀行名、ポイント名など", text: $balNm)
                            .focused($addBalNmFocused)
                            .padding(5)
                            .background(Color(uiColor: .systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .font(.caption.bold())
                            .frame(width: rectWidth * (2 / 3))
                    }
                    HStack(spacing: 0) {
                        Text("金額初期設定")
                            .font(.caption2.bold())
                            .frame(width: rectWidth / 3, alignment: .leading)
                        TextField("", text: $initBalAmount)
                            .focused($addBalInitAmountFocused)
                            .padding(5)
                            .background(Color(uiColor: .systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .multilineTextAlignment(.trailing)
                            .font(.caption.bold())
                            .frame(width: rectWidth * (2 / 3))
                            .keyboardType(.numberPad)
                    }
                    HStack(spacing: 0) {
                        Text("識別カラー")
                            .font(.caption2.bold())
                            .frame(width: rectWidth / 3, alignment: .leading)
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
                        }.frame(width: rectWidth * (2 / 3))
                            .scrollIndicators(.hidden)
                    }
                }.frame(height: rectHeight - 40)
                    .padding(.horizontal, 15)
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            self.popUpFlg = false
                            self.balNm = ""
                            self.initBalAmount = "0"
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
                            balanceService.registBalance(balanceNm: balNm,
                                                         balAmt: Int(initBalAmount) ?? 0,
                                                         colorIndex: colorIndex)
                            self.popUpFlg = false
                            self.balNm = ""
                            self.initBalAmount = "0"
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
            .offset(y: addBalNmFocused ? -40 : addBalInitAmountFocused ? -30 : 0)
            .animation(.linear, value: addBalNmFocused)
            .animation(.linear, value: addBalInitAmountFocused)
            .frame(width: rectWidth, height: rectHeight)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Button(action: {
                            if addBalNmFocused {
                                self.balNm = ""
                                self.addBalNmFocused = false
                            } else if addBalInitAmountFocused {
                                self.initBalAmount = "0"
                                self.addBalInitAmountFocused = false
                            }
                        }) {
                            Text("キャンセル")
                        }
                        Spacer()
                        Button(action: {
                            if addBalNmFocused {
                                self.addBalNmFocused = false
                            } else if addBalInitAmountFocused {
                                if self.initBalAmount == "" {
                                    self.initBalAmount = "0"
                                }
                                self.addBalInitAmountFocused = false
                            }
                        }) {
                            Text("完了")
                        }
                    }
                }
            }.onChange(of: addBalInitAmountFocused) {
                if addBalInitAmountFocused && self.initBalAmount == "0" {
                    self.initBalAmount = ""
                }
            }
    }
    // 残高編集アラート
    @ViewBuilder
    func editBalanceFormAlert() -> some View {
        let rectWidth: CGFloat = 300
        let rectHeight: CGFloat = 200
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack {
                VStack {
                    Text("残高変更")
                        .fontWeight(.bold)
                    HStack(spacing: 0) {
                        Text("残高名(必須)")
                            .font(.caption2.bold())
                            .frame(width: rectWidth / 3, alignment: .leading)
                        TextField("銀行名、ポイント名など", text: $balNm)
                            .focused($addBalNmFocused)
                            .padding(5)
                            .background(Color(uiColor: .systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .font(.caption.bold())
                            .frame(width: rectWidth * (2 / 3))
                    }
                    HStack(spacing: 0) {
                        Text("識別カラー")
                            .font(.caption2.bold())
                            .frame(width: rectWidth / 3, alignment: .leading)
                        ScrollView(.horizontal) {
                            ScrollViewReader { proxy in
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
                            }
                        }.frame(width: rectWidth * (2 / 3))
                            .scrollIndicators(.hidden)
                            .id(self.colorIndex)
                    }
                }.frame(height: rectHeight - 40)
                    .padding(.horizontal, 15)
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            self.popUpFlg = false
                            self.balNm = ""
                            self.initBalAmount = "0"
                            self.colorIndex = 0
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
                            balanceService.updateBalance(balKey: balKey,
                                                         balNm: balNm,
                                                         colorIndex: colorIndex)
                            
                            self.popUpFlg = false
                            self.balNm = ""
                            self.initBalAmount = "0"
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
            .offset(y: addBalNmFocused ? -40 : addBalInitAmountFocused ? -30 : 0)
            .animation(.linear, value: addBalNmFocused)
            .animation(.linear, value: addBalInitAmountFocused)
            .frame(width: rectWidth, height: rectHeight)
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Button(action: {
                            if addBalNmFocused {
                                self.balNm = ""
                                self.addBalNmFocused = false
                            } else if addBalInitAmountFocused {
                                self.initBalAmount = "0"
                                self.addBalInitAmountFocused = false
                            }
                        }) {
                            Text("キャンセル")
                        }
                        Spacer()
                        Button(action: {
                            if addBalNmFocused {
                                self.addBalNmFocused = false
                            } else if addBalInitAmountFocused {
                                if self.initBalAmount == "" {
                                    self.initBalAmount = "0"
                                }
                                self.addBalInitAmountFocused = false
                            }
                        }) {
                            Text("完了")
                        }
                    }
                }
            }.onChange(of: addBalInitAmountFocused) {
                if addBalInitAmountFocused && self.initBalAmount == "0" {
                    self.initBalAmount = ""
                }
            }
    }
    // 残高削除アラート
    @ViewBuilder
    func deleteBalanceAlert() -> some View {
        let rectWidth: CGFloat = 300
        let rectHeight: CGFloat = 150
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack {
                VStack {
                    Text("残高削除")
                        .fontWeight(.bold)
                    Text("残高を削除してよろしいですか。")
                        .font(.caption.bold())
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
                            balanceService.deleteBalance(balanceKey: balKey)
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
    // 成功・失敗アラート
    @ViewBuilder
    func SuccessFailedPopUp() -> some View {
        var count = 2
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack(spacing: 5) {
                Image(systemName: imageNm)
                    .font(.largeTitle.bold())
                    .foregroundStyle(self.status == .success ? Color.green : Color.red)
                Text(text)
                    .foregroundStyle(Color.changeableText)
                    .fontWeight(.bold)
            }
        }.clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(width: 200, height: 100)
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
                }
            }
    }
}

#Preview {
    @State var popUpFlg = false
    return PopUpView(accentColors: [.purple, .indigo], popUpFlg: $popUpFlg, status: .success)
}
