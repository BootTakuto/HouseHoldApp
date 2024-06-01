//
//  RegistIncConsForm.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/03/17.
//

import SwiftUI
import RealmSwift

struct RegistIncConsFormView: View {
    @Binding var registIncConsFlg: Bool
    var accentColors: [Color]
    var isEdit: Bool
    /** 登録情報 */
    @State var selectForm = 0                               // 選択フォーム　※
    @State var linkBalFlg = true                            // 収支登録時の残高連携フラグ　※
    @State private var inputAmt = "0"                       // 金額(残高未連携)
    @State var balKeyArray: [String] = []           // 金額(残高連携用 残高主キー配列)
    @State var linkBalAmtArray: [IncConsBalLinkAmtModelForView] = []
    @State var incConsSecKey =
    IncConSecCatgService().getUnCatgSecKey(houseHoldType: 0)// 項目主キー
    @State var incConsCatgKey =
    IncConSecCatgService().getUnCatgCatgKey(houseHoldType: 0)// 項目カテゴリー主キー
    @State var selectDate = Date()                  // 日付
    @State var memo = ""                            // メモ
    /** 表示 */
    @State private var dateDownFlg = false                  // 日付ピッカーの開閉フラグ　※
    @State private var popUpFlg = false                     // ポップアップ画面フラグ　　※
    @State private var popUpStatus: PopUpStatus = .failed   // ポップアップ画面ステータス※
    @FocusState var inputAmtFocused                         // 収支金額入力フォーカス　　※
    @FocusState var isMemoFocused                           // メモ入力フォーカス　　　　※
    @State private var inputLeastIndex = 0                  // 入力キャンセル用　残高連携入力箇所を特定するため　※
    @State private var isChekAmtTotal = false               // 残高連携金額確認表示フラグ　※
    @State private var inputAmtTotal = 0                    // 残高連携金額確認で表示する合計金額　※
    /** results */
    @State private var sectionResults = IncConSecCatgService().getIncConsSec(houseHoldType: 0)
    let balResults = BalanceService().getBalanceResults()
    /** 汎用ビュー */
    let generalView = GeneralComponentView()
    /** service */
    let incConsService = IncomeConsumeService()
    let calendarService = CalendarService()
    let balanceService = BalanceService()
    let incConsSecCatgService = IncConSecCatgService()
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                NavigationStack {
                    VStack(spacing: 0) {
                        headerAndTab(size: size)
                        if !isEdit {
                            TabView(selection: $selectForm) {
                                registIncForm(size: size)
                                    .tag(0)
                                registConsForm(size: size)
                                    .tag(1)
                                registOthersForm(size: size)
                                    .tag(2)
                            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        } else {
                            switch self.selectForm {
                            case 0:
                                registIncForm(size: size)
                            case 1:
                                registConsForm(size: size)
                            case 2:
                                registOthersForm(size: size)
                            default:
                                Text("収支情報が存在しません。")
                            }
                        }
                    }
                }
            }.onChange(of: selectForm) {
//                self.dateDownFlg = true
//                self.inputAmtFocused = false
                self.isMemoFocused = false
                self.memo = ""
                if self.selectForm == 2 {
                    self.linkBalFlg = true
                    self.incConsSecKey = ""
                    self.incConsCatgKey = ""
                } else {
                    self.sectionResults = incConsSecCatgService.getIncConsSec(houseHoldType: self.selectForm)
                    // タブが変更されたタイミングで選択を「未分類」の項目キー、カテゴリーキーに変更する
                    self.incConsSecKey = incConsSecCatgService.getUnCatgSecKey(houseHoldType: self.selectForm)
                    self.incConsCatgKey = incConsSecCatgService.getUnCatgCatgKey(houseHoldType: self.selectForm)
                }
//                    self.linkBalFlg = false
                self.balKeyArray.removeAll()
                self.linkBalAmtArray.removeAll()
//                self.registAmtFormAr.indices.forEach { index in
//                    if self.amountArray[index] == "" {
//                        self.amountArray[index] = "0"
//                    }
//                }
            }.onChange(of: inputLeastIndex) {
                self.linkBalAmtArray.indices.forEach { index in
                    if self.inputLeastIndex != index && self.linkBalAmtArray[index].incConsAmt == "" {
                        self.linkBalAmtArray[index].incConsAmt = "0"
                    }
                }
            }.onChange(of: inputAmtFocused) {
                if inputAmtFocused {
                    self.inputAmt = ""
                } else {
                    if self.inputAmt == "" {
                        self.inputAmt = "0"
                    }
                }
            }.custumFullScreenCover(isPresented: $popUpFlg, transition: .opacity) {
                if self.popUpStatus == .addBalance {
                    PopUpView(accentColors: accentColors,
                              popUpFlg: $popUpFlg,
                              status: popUpStatus)
                } else if self.popUpStatus == .success {
                    PopUpView(accentColors: accentColors,
                              popUpFlg: $popUpFlg,
                              status: popUpStatus,
                              text: "登録成功",
                              imageNm:"checkmark.circle")
                } else if self.popUpStatus == .failed {
                    PopUpView(accentColors: accentColors,
                              popUpFlg: $popUpFlg,
                              status: popUpStatus,
                              text: "登録失敗",
                              imageNm:"xmark.circle")
                }
            }.toolbar {
                if self.inputAmtFocused {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Button("キャンセル") {
                                self.inputAmt = "0"
                                if !linkBalAmtArray.isEmpty {
                                    self.linkBalAmtArray[inputLeastIndex].incConsAmt = "0"
                                }
                                self.inputAmtFocused = false
                            }
                            Spacer()
                            Button("完了") {
                                if inputAmt == "" {
                                    self.inputAmt = "0"
                                }
                                self.linkBalAmtArray.indices.forEach { index in
                                    if self.linkBalAmtArray[index].incConsAmt == "" {
                                        self.linkBalAmtArray[index].incConsAmt = "0"
                                    }
                                }
                                self.inputAmtFocused = false
                            }
                        }
                    }
                }
            }.onAppear {
                if isEdit {
                    self.sectionResults = incConsSecCatgService.getIncConsSec(houseHoldType: self.selectForm)
                }
            }
        }
    }

    @ViewBuilder
    func headerAndTab(size: CGSize) -> some View {
        ZStack(alignment: .top) {
            if isEdit {
                Color(uiColor: .systemGray6)
                    .ignoresSafeArea()
                    .frame(height: 70)
            } else {
                LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                    .frame(height: 70)
            }
            VStack {
                HStack {
                    Image(systemName: isEdit ? "chevron.left" : "xmark")
                        .foregroundStyle(isEdit ? Color.changeableText : .white)
                        .onTapGesture {
                            self.registIncConsFlg = false
                        }
                    Spacer()
                    Image(systemName: "questionmark.circle")
                        .foregroundStyle(isEdit ? Color.changeableText : .white)
                }.padding(.horizontal, 20)
                formTabBar()
                    .padding(.vertical, 10)
                    .disabled(isEdit)
            }
        }
    }
    
    @ViewBuilder
    func formTabBar() -> some View {
        VStack {
            GeometryReader { geometry in
                let local = geometry.frame(in: .local)
                let offset = (local.width / 3) / 3
                let offsets: [CGFloat] = [offset - 15, offset * 4 - 15, offset * 7 - 15]
                HStack(spacing: 0) {
                    Group {
                        Text(isEdit && selectForm != 0 ? "" : "収入")
                            .onTapGesture {
                                withAnimation {
                                    self.selectForm = 0
                                }
                            }
                        Text(isEdit && selectForm != 1 ? "" : "支出")
                            .onTapGesture {
                                withAnimation {
                                    self.selectForm = 1
                                }
                            }
                        Text(isEdit && selectForm != 2 ? "" : "残高操作")
                            .onTapGesture {
                                withAnimation {
                                    self.selectForm = 2
                                }
                            }
                    }.frame(width: local.size.width / 3)
                }.font(.system(size: 14).bold())
                    .foregroundStyle(isEdit ? Color.changeableText : .white)
                RoundedRectangle(cornerRadius: 25)
                    .fill(isEdit ? Color.changeableText : .white)
                    .frame(width: local.width / 9 + 30, height: 5)
                    .animation(
                        .spring(), value: selectForm
                    ).offset(x: offsets[selectForm], y: local.maxY)
            }
        }.frame(height: 20)
    }
    
    @ViewBuilder
    func toggleLinkBalance() -> some View {
        let rectColor = !linkBalFlg ?
            Color(uiColor: .systemGray3).shadow(.inner(radius:1)) : !isEdit ?
            accentColors.last!.shadow(.inner(radius: 3)) : Color.gray.shadow(.inner(radius: 3))
        HStack {
            Text(linkBalFlg ? "残高選択(複数可)" : "金 額")
                .font(.caption.bold())
                .foregroundStyle(Color.changeableText)
            Spacer()
            if self.selectForm != 2 {
                Text("残高と連携")
                    .font(.caption.bold())
                    .foregroundStyle(Color.changeableText)
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(rectColor)
                        .frame(width: 50, height: 25)
                    Circle()
                        .fill(.changeable)
                        .frame(width: 22)
                        .offset(x: linkBalFlg ?  25 / 2 : -25 / 2)
                }.onTapGesture {
                    // 残高連携がfalseになるタイミングで連携情報をクリア
                    if self.linkBalFlg {
                        self.balKeyArray.removeAll()
                        self.linkBalAmtArray.removeAll()
                    }
                    withAnimation {
                        self.linkBalFlg.toggle()
                    }
                }
            }
        }.frame(height: 25)
    }
    
    @ViewBuilder
    func textFieldLinkBal(size: CGSize, index: Int) -> some View {
        let linkBalAmtObj = self.linkBalAmtArray[index]
        let balResult = balanceService.getBalanceResult(balanceKey: linkBalAmtObj.balanceKey)
        let width = size.width - 60 - 30 - 20 - 10
        ZStack {
            if isEdit {
                UIGlassCard(effect: .systemUltraThinMaterial)
            } else {
                Color.changeable
            }
            HStack(spacing: 0) {
                Rectangle().fill(ColorAndImage.colors[balResult.colorIndex])
                    .frame(width: 10)
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 0) {
                        Text(balResult.balanceNm)
                            .fontWeight(.bold)
                            .frame(width: width * (3 / 5), alignment: .leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Spacer()
                        if self.selectForm == 2 {
                            HStack {
                                Button(action: {
                                    withAnimation {
                                        self.linkBalAmtArray[index].isIncreaseBal = true
                                    }
                                }) {
                                    Circle()
                                        .stroke(lineWidth: 1)
                                        .fill(isEdit ? Color.gray : accentColors.last ?? .blue)
                                        .frame(width: 15)
                                        .overlay {
                                            Circle()
                                                .fill(linkBalAmtObj.isIncreaseBal ? isEdit ? .gray :
                                                      accentColors.last ?? .blue : .clear)
                                                .frame(width: 10)
                                        }
                                }
                                Text("増額")
                                Button(action: {
                                    withAnimation {
                                        self.linkBalAmtArray[index].isIncreaseBal = false
                                    }
                                }) {
                                    Circle()
                                        .stroke(lineWidth: 1)
                                        .fill(isEdit ? Color.gray : accentColors.last ?? .blue)
                                        .frame(width: 15)
                                        .overlay {
                                            Circle()
                                                .fill(linkBalAmtObj.isIncreaseBal ?
                                                    .clear : isEdit ? .gray : accentColors.last ?? .blue)
                                                .frame(width: 10)
                                        }
                                }
                                Text("減額")
                            }
                        }
                    }.padding(.horizontal, 15)
                        .font(.caption.bold())
                        .foregroundStyle(Color.changeableText)
                    if isEdit {
                        HStack {
                            Spacer()
                            Text(linkBalAmtObj.isIncreaseBal ?
                                 "+\(linkBalAmtObj.incConsAmt)" : "-\(linkBalAmtObj.incConsAmt)")
                            .foregroundStyle(linkBalAmtObj.isIncreaseBal ? .blue : .red)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                        }.padding(.horizontal, 15)
                    } else {
                        Text("¥\(balResult.balanceAmt)")
                            .font(.caption.bold())
                            .fontDesign(.rounded)
                            .foregroundStyle(Color.changeableText)
                            .padding(.horizontal, 15)
                            .frame(width: width * (3 / 4), alignment: .leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        TextField("", text: $linkBalAmtArray[index].incConsAmt)
                            .focused($inputAmtFocused)
                            .padding(10)
                            .padding(.horizontal, 10)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                            .foregroundStyle(linkBalAmtObj.isIncreaseBal ? .blue : .red)
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .background(
                                generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                                    .frame(height: 50)
                                    .padding(.horizontal, 10)
                            ).onTapGesture {
                                if self.linkBalAmtArray[index].incConsAmt == "0" {
                                    self.linkBalAmtArray[index].incConsAmt = ""
                                }
                                self.inputLeastIndex = index
                            }
                    }
                }
            }
        }.clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(height: isEdit ? 80 : 110)
            .compositingGroup()
            .shadow(color: isEdit ? .clear : .changeableShadow, radius: 3)
    }
    
    @ViewBuilder
    func textFieldNotLinkBal() -> some View {
        TextField("", text: $inputAmt)
            .focused($inputAmtFocused)
            .padding(10)
            .multilineTextAlignment(.trailing)
            .keyboardType(.numberPad)
            .foregroundStyle(self.selectForm == 0 ? .blue : self.selectForm == 1 ? .red : Color.changeableText)
            .font(.title3.bold())
            .background(
                generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                    .frame(height: 50)
            )
    }
    
    @ViewBuilder
    func balMiniIcon(balResult: BalanceModel) -> some View {
        let isSelected = self.balKeyArray.contains(balResult.balanceKey)
        ZStack {
            if isSelected {
                UIGlassCard(effect: .systemUltraThinMaterial)
            } else {
                Color.changeable
            }
            HStack(spacing: 0) {
                Image(systemName: isSelected ? "checkmark.circle" : "circle")
                    .font(.subheadline.bold())
                    .foregroundStyle(isEdit ? .gray : accentColors.last ?? .blue)
                    .padding(.horizontal, 5)
                Text(balResult.balanceNm)
                    .font(.caption2.bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.trailing, 5)
            }.foregroundStyle(Color.changeableText)
                .frame(maxWidth: 150, alignment: .leading)
                .frame(minWidth: 80)
        }.clipShape(RoundedRectangle(cornerRadius: 25))
            .frame(height: 30)
            .compositingGroup()
            .shadow(color: .changeableShadow, radius: isSelected ? 0 : 3)
            .padding(.vertical, 5)
            .padding(.horizontal, 2)
    }
    
    @ViewBuilder
    func checkAmtTotalCard() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.changeable)
                .shadow(color: .changeableShadow, radius: 3)
                .frame(height: 80)
            VStack {
                Text("\(inputAmtTotal)")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .foregroundStyle(selectForm == 0 ? .blue : .red)
                Text(selectForm == 0 ? "収入額合計" : "支出額合計")
                    .font(.caption.bold())
                    .foregroundStyle(Color.changeableText)
            }.padding(10)
        }
    }
    
    @ViewBuilder
    func inputForm(size: CGSize) -> some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Group {
                        toggleLinkBalance()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.top, 20)
                            .disabled(isEdit)
                        if self.linkBalFlg {
                            if self.balResults.isEmpty {
                                VStack {
                                    Text("残高が存在しません。")
                                        .font(.caption.bold())
                                        .foregroundStyle(Color.changeableText)
                                    generalView.glassTextRounedButton(color: accentColors.last ?? .blue,
                                                                      text: "追加", imageNm: "plus", radius: 25) {
                                        withAnimation {
                                            self.popUpStatus = .addBalance
                                            self.popUpFlg = true
                                        }
                                    }.frame(width: 100, height: 25)
                                        .compositingGroup()
                                        .shadow(color: .changeableShadow, radius: 3)
                                }.frame(width: size.width - 40)
                            } else {
                                ScrollView(.horizontal) {
                                    HStack {
                                        ForEach(balResults.indices, id: \.self) {index in
                                            let result = balResults[index]
                                            balMiniIcon(balResult: result)
                                                .onTapGesture {
                                                    withAnimation {
                                                        if !balKeyArray.contains(result.balanceKey) {
                                                            self.balKeyArray.append(result.balanceKey)
                                                            self.linkBalAmtArray.append(
                                                               IncConsBalLinkAmtModelForView(
                                                                balanceKey: result.balanceKey,
                                                                incConsAmt: "0",
                                                                isIncreaseBal: selectForm != 1 ? true : false)
                                                            )
                                                        } else {
                                                            let index = balKeyArray.firstIndex(of: result.balanceKey)!
                                                            self.balKeyArray.remove(at: index)
                                                            self.linkBalAmtArray.remove(at: index)
                                                        }
                                                    }
                                                }
                                        }.disabled(isEdit)
                                        if !isEdit {
                                            generalView.glassCircleButton(imageColor: accentColors.last ?? .blue,
                                                                          imageNm: "plus") {
                                                withAnimation {
                                                    self.inputAmtFocused = false
                                                    self.popUpStatus = .addBalance
                                                    self.popUpFlg = true
                                                }
                                            }.frame(width: 25)
                                                .compositingGroup()
                                                .shadow(color: .changeableShadow, radius: 3)
                                                .padding(.horizontal, 5)
                                        }
                                    }.padding(.leading, 5)
                                }.scrollDisabled(balResults.isEmpty)
                            }
                            if !linkBalAmtArray.isEmpty {
                                HStack {
                                    Text("金 額")
                                        .font(.caption.bold())
                                        .foregroundStyle(Color.changeableText)
                                    Spacer()
                                    Button(action: {
                                        self.inputAmtTotal = 0
                                        linkBalAmtArray.forEach { data in
                                            if data.isIncreaseBal {
                                                self.inputAmtTotal += Int(data.incConsAmt) ?? 0
                                            } else {
                                                self.inputAmtTotal -= Int(data.incConsAmt) ?? 0
                                            }
                                        }
                                        withAnimation {
                                            self.isChekAmtTotal.toggle()
                                        }
                                    }) {
                                        Text(self.isChekAmtTotal ? "閉じる" : "確認")
                                            .font(.caption.bold())
                                            .foregroundStyle(accentColors.last ?? .blue)
                                    }
                                }
                            }
                            if isChekAmtTotal {
                                checkAmtTotalCard()
                            } else {
                                VStack(spacing: isEdit ? 10 : 15) {
                                    ForEach(linkBalAmtArray.indices, id: \.self) {index in
                                        textFieldLinkBal(size: size, index: index)
                                    }.disabled(isEdit)
                                }
                            }
                        } else {
                            textFieldNotLinkBal()
                        }
                        let sectionText = self.selectForm == 0 ? "収入項目" : "支出項目"
                        if self.selectForm != 2 {
                            Text(sectionText)
                                .font(.caption.bold())
                                .foregroundStyle(Color.changeableText)
                            ScrollView(.horizontal) {
                                LazyHStack {
                                    ForEach(self.sectionResults.indices, id:\.self) { secIndex in
                                        let result = sectionResults[secIndex]
                                        let colorIndex = result.incConsSecColorIndex
                                        let color = ColorAndImage.colors[colorIndex]
                                        let imageNm = result.incConsSecImage
                                        let secNm = result.incConsSecName
                                        let isSelectSec = result.incConsSecKey == self.incConsSecKey
                                        Menu {
                                            ForEach(result.incConsCatgOfSecList.indices, id: \.self) { catgIndex in
                                                let catg = result.incConsCatgOfSecList[catgIndex]
                                                let isSelectCatg = catg.incConsCatgKey == self.incConsCatgKey
                                                Button(action: {
                                                    withAnimation {
                                                        self.incConsSecKey = catg.incConsSecKey
                                                        self.incConsCatgKey = catg.incConsCatgKey
                                                    }
                                                }) {
                                                    Text("\(catg.incConsCatgNm)")
                                                    if isSelectCatg {
                                                        Image(systemName: "checkmark")
                                                    }
                                                }
                                            }
                                        } label: {
                                            ZStack {
                                                generalView.RoundedIcon(radius: 10,
                                                                        color: isEdit && !isSelectSec ? .gray : color,
                                                                        image: imageNm, text: secNm,
                                                                        isSelected: isSelectSec)
                                                .frame(width: 50, height: 50)
                                            }
                                        }.padding(.vertical, 5)
                                    }.disabled(isEdit)
                                }.padding(.horizontal, 5)
                            }.scrollIndicators(.hidden)
                        }
                        Text(LabelsModel.dateLabel)
                            .font(.caption.bold())
                            .foregroundStyle(Color.changeableText)
                        ZStack {
                            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                                .frame(height: self.dateDownFlg ? 350 : 60)
                                .onTapGesture {
                                    withAnimation {
                                        self.dateDownFlg.toggle()
                                    }
                                }.disabled(isEdit)
                            VStack(spacing: 3) {
                                if self.dateDownFlg {
                                    DatePicker("", selection: $selectDate, displayedComponents: .date)
                                        .datePickerStyle(.graphical)
                                        .frame(height: 300)
                                        .padding(.horizontal, 10)
                                        .tint(accentColors.last!)
                                        .environment(\.locale, Locale(identifier: "ja_JP"))
                                } else {
                                    Text(calendarService.getStringDate(date: selectDate, format: "yyyy年MM月dd日"))
                                        .foregroundStyle(Color.changeableText)
                                        .font(.callout.bold())
                                }
                                if !isEdit {
                                    Image(systemName: "chevron.compact.down")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 20)
                                        .rotationEffect(.degrees(self.dateDownFlg ? 180 : 0))
                                        .foregroundStyle(Color.changeableText)
                                }
                            }
                        }
                        Text(LabelsModel.memoLabel)
                            .font(.caption.bold())
                            .foregroundStyle(Color.changeableText)
                            .padding(.vertical, 5)
                        ZStack {
                            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                                .frame(height: 100)
                            TextEditor(text: $memo)
                                .scrollContentBackground(.hidden)
                                .focused($isMemoFocused)
                                .foregroundStyle(Color.changeableText)
                                .disabled(isEdit)
                        }
                    }.padding(.horizontal, 20)
                    // 登録
                    if !isEdit {
                        generalView.registButton(colors: accentColors, radius: 10, isDisAble: isEdit) {
                            if linkBalFlg {
                                withAnimation {
                                    self.popUpFlg = true
                                    self.popUpStatus =
                                    incConsService.registIncConsLinkBal(balKeyArray: self.balKeyArray,
                                                                        linkBalAmtArray: self.linkBalAmtArray,
                                                                        houseHoldType: self.selectForm,
                                                                        incConsSecKey: self.incConsSecKey,
                                                                        incConsCatgKey: self.incConsCatgKey,
                                                                        incConsDate: self.selectDate,
                                                                        memo: self.memo)
                                }
                                self.balKeyArray.removeAll()
                                self.linkBalAmtArray.removeAll()
                                self.memo = ""
                                
                                self.isChekAmtTotal = false
                            } else {
                                withAnimation {
                                    self.popUpFlg = true
                                    self.popUpStatus =
                                    incConsService.registIncConsNotLikBal(houseHoldType: self.selectForm,
                                                                          incConsSecKey: self.incConsSecKey,
                                                                          incConsCatgKey: self.incConsCatgKey,
                                                                          inputAmt: Int(self.inputAmt) ?? 0,
                                                                          incConsDate: self.selectDate,
                                                                          memo: self.memo)
                                }
                                self.memo = ""
                            }
                        }.frame(height: 70)
                            .shadow(color: .changeableShadow, radius: 3)
                    }
                }
            }.scrollIndicators(.hidden)
        }
    }

    // 収入登録
    @ViewBuilder
    func registIncForm(size: CGSize) -> some View {
        inputForm(size: size)
    }
    // 支出登録
    @ViewBuilder
    func registConsForm(size: CGSize) -> some View {
        inputForm(size: size)
    }
    // その他金額操作
    @ViewBuilder
    func registOthersForm(size: CGSize) -> some View {
        inputForm(size: size)
    }
}

//#Preview {
//    @State var registIncConsFlg = true
//    @State var accentColors: [Color] = [.purple, .indigo]
//    return RegistIncConsFormView(registIncConsFlg: $registIncConsFlg,
//                                 accentColors: accentColors,
//                                 isEdit: false)
//}

#Preview {
    ContentView()
}
