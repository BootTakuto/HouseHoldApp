//
//  PopUpView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/05/05.
//

import SwiftUI

struct PopUpView: View {
    /** 共通 */
    @State var accentColors: [Color]
    @Binding var popUpFlg: Bool
   
    var status: PopUpStatus
    /** 残高登録アラート情報(.addBal) */
    @FocusState var addBalNmFocused
    @FocusState var addBalInitAmountFocused
    @State var balNm = ""
    @State var initBalAmount = "0"
    @State var colorIndex = 0
    @State var balKey = ""
    /** 削除アラート */
    var delTitle = ""
    var delExplain = ""
    var incConsSecKey = ""
    var incConsCatgKey = ""
    /** 入力アラート */
    var inputTitle = ""
    var inputExplain = ""
    var inputPlaceHolder = ""
    @State var inputText = ""
    /** アクセントカラー選択 */
    @AppStorage("ACCENT_COLORS_INDEX") var accentColorsIndex = 0
    /** 収入・支出項目登録 */
    @FocusState var addIncConsNmFocused
    @State var houseHoldType = 0
    @State var incConsSecNm = ""
    @State var incConsColorIndex = 0
    @State var incConsImageNm = ColorAndImage.imageNames[0]
    /** 成功・失敗アラート(.sucess, .fail) */
    @State var text = ""
    @State var imageNm = ""
    
    // service
    let balanceService = BalanceService()
    let incConsSecCatgService = IncConSecCatgService()
    // 汎用ビュー
    let generalView = GeneralComponentView()
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            switch status {
            case .addBalance:
                addBalanceFormAlert()
            case .editBalance:
                editBalanceFormAlert()
            case .deleteBalance:
                deleteAlert(title: delTitle, explain: delExplain)
            case .selectAccentColor:
                selectAccentColorAlert()
            case .success:
                SuccessFailedPopUp()
            case .failed:
                SuccessFailedPopUp()
            case .addIncConsSec:
                AddAndEditIncConSecAlert()
            case .editIncConsSec:
                AddAndEditIncConSecAlert()
            case .deleteIncConsSec:
                deleteAlert(title: delTitle, explain: delExplain)
            case .addincConsCatg:
                InputAlert()
            case .editIncConsCatg:
                InputAlert()
            case .deleteIncConsCatg:
                deleteAlert(title: delTitle, explain: delExplain)
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
    func deleteAlert(title: String, explain: String) -> some View {
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
                        if self.status == .deleteBalance {
                            balanceService.deleteBalance(balanceKey: balKey)
                        } else if self.status == .deleteIncConsSec {
                            incConsSecCatgService.deleteIncConsSec(incConsSecKey: incConsSecKey)
                        } else if self.status == .deleteIncConsCatg {
                            incConsSecCatgService.deleteIncConsCatg(catgKey: incConsCatgKey)
                        }
                        withAnimation {
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
    // テーマカラー選択アラート
    @ViewBuilder
    func selectAccentColorAlert() -> some View {
        let rectWidth: CGFloat = 250
        let rectHeight: CGFloat = 250
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack {
                Text("テーマカラー")
                    .foregroundStyle(Color.changeableText)
                    .fontWeight(.bold)
                    .padding(.vertical, 15)
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
    // 成功・失敗アラート
    @ViewBuilder
    func SuccessFailedPopUp() -> some View {
        var count = 2
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack(spacing: 5) {
                Image(systemName: imageNm)
                    .font(.largeTitle)
                    .fontWeight(.medium)
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
    
    @ViewBuilder
    func AddAndEditIncConSecAlert() -> some View {
        let rectHeight: CGFloat = 500
        let isEdit = self.status == .editIncConsSec
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack(spacing: 0) {
                VStack {
                    Text(isEdit ? "項目の変更" : "項目の登録")
                        .fontWeight(.bold)
                    HStack {
                        Text("項目名(必須)")
                            .font(.caption)
                            .fontWeight(.medium)
                        TextField("収入、食費・交通費など", text: $incConsSecNm)
                            .focused($addIncConsNmFocused)
                            .padding(5)
                            .background(Color(uiColor: .systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .font(.caption.bold())
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    Text("イメージ")
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0 ..< 11, id: \.self) { row in
                                VStack {
                                    ForEach(0 ..< 3, id: \.self) { col in
                                        let index = col + (row * 3)
                                        if ColorAndImage.imageNames.count > index {
                                            let incConsImageNm = ColorAndImage.imageNames[index]
                                            Button(action: {
                                                self.incConsImageNm = incConsImageNm
                                            }) {
                                                ZStack {
                                                    if self.incConsImageNm == incConsImageNm {
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(ColorAndImage.colors[self.incConsColorIndex])
                                                    } else {
                                                        generalView.GlassBlur(effect: .systemThinMaterial, radius: 10)
                                                    }
                                                    Image(systemName: incConsImageNm)
                                                        .fontWeight(.medium)
                                                        .foregroundStyle(self.incConsImageNm == incConsImageNm ? .white : Color.changeableText)
                                                }
                                            }.frame(width: 40, height: 40)
                                        } else {
                                            Color.clear
                                                .frame(width: 40, height: 40)
                                        }
                                    }
                                }
                            }
                        }
                    }.frame(height: rectHeight / 4 + 20)
                    Text("カラー")
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0 ..< 10, id: \.self) { row in
                                VStack {
                                    ForEach(0 ..< 3, id: \.self) { col in
                                        let index = col + (row * 3)
                                        if ColorAndImage.colors.count > index {
                                            Button(action: {
                                                self.incConsColorIndex = index
                                            }) {
                                                let color = ColorAndImage.colors[index]
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(color)
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 6.5)
                                                            .stroke(lineWidth: 3)
                                                            .fill(self.incConsColorIndex == index ? .white : .clear)
                                                            .frame(width: 30, height: 30)
                                                    )
                                            }
                                        } else {
                                            Color.clear
                                                .frame(width: 40, height: 40)
                                        }
                                    }
                                }
                            }
                        }
                    }.frame(height: rectHeight / 4 + 20)
                }.padding(.top, 20)
                    .padding(.horizontal, 20)
                Spacer()
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
                        if isEdit {
                            incConsSecCatgService.updateIncConsSec(incConsSecKey: self.incConsSecKey,
                                                                   incConsSecNm: self.incConsSecNm,
                                                                   incConsSecColorIndex: self.incConsColorIndex,
                                                                   incConsSecImageNm: self.incConsImageNm)
                        } else {
                            incConsSecCatgService.registIncConsSec(houseHoldType: self.houseHoldType,
                                                                   sectionNm: self.incConsSecNm,
                                                                   colorIndex: self.incConsColorIndex,
                                                                   imageNm: self.incConsImageNm)
                        }
                        withAnimation {
                            self.popUpFlg = false
                        }
                    }) {
                        ZStack {
                            accentColors.last ?? .black
                            Text(isEdit ? "変更" : "保存")
                        }
                    }
                }.frame(height: 40)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }.foregroundStyle(Color.changeableText)
        }.frame(height: rectHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func InputAlert() -> some View {
        let isWithoutExplain = inputExplain.count == 0
        let rectHeight: CGFloat = isWithoutExplain ? 150 : 200
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack {
                Text(inputTitle)
                    .fontWeight(.bold)
                if !isWithoutExplain {
                    Text(inputExplain)
                        .font(.caption)
                        .fontWeight(.bold)
                }
                TextField(inputPlaceHolder, text: $inputText)
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
                            accentColors.last ?? .black
                            Text("キャンセル")
                        }
                    }
                    generalView.Bar()
                        .foregroundStyle(.changeable)
                    Button(action: {
                        withAnimation {
                            if status == .addincConsCatg {
                                incConsSecCatgService.registIncConsCatg(catgNm: self.inputText,
                                                                        incConsSecKey: self.incConsSecKey)
                            } else if status == .editIncConsCatg {
                                incConsSecCatgService.updateIncConsCatg(catgNm: self.inputText,
                                                                        incConsCatgKey: self.incConsCatgKey)
                            }
                            self.popUpFlg = false
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
                .padding(.top, 20)
        }.frame(height: rectHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)
        
    }
}

#Preview {
    @State var popUpFlg = false
    return PopUpView(accentColors: [.purple, .indigo],
                     popUpFlg: $popUpFlg,
                     status: .addincConsCatg,
                     inputTitle: "カテゴリーの登録")
}
