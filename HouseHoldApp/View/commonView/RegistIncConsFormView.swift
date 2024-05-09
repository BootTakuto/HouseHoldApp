//
//  RegistIncConsForm.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/03/17.
//

import SwiftUI
import RealmSwift

struct RegistIncConsFormView: View {
    @Binding var showFlg: Bool
    var accentColors: [Color]
    /** 入力値フォーム */
    @State var amtBalkeyDic: [String: Int] = [:]
    @State var incConsSecKey: String = ""
    @State var incConsCatgKey: String = ""
    @State var selectDate = Date()
    @State var memo = ""
    /** View表示関連 */
    @State private var selectForm = 0
    @State private var selectIncFlg = true
    @State private var assetsFlg = true
    @State private var dateDownFlg = true
    @State private var inputAmtDownFlg = false
    @State private var inputAmtTotal = 0
    // 金額入力関連
    @State private var selectBalKeys: [String] = []
    @State private var tapTextFieldIndex = 0
    @FocusState var isInputAmtFocused
    @FocusState var isMemoFocused
    /** アラート登録関連 */
    // 残高登録
    @State private var addBalAlertFlg = false
    @State private var balanceNm = ""
    // results
    @ObservedResults(IncConsSectionModel.self) var incConsSecResults
    @ObservedResults(IncConsSectionModel.self, where: {$0.incFlg}) var incSecResults
    @ObservedResults(IncConsSectionModel.self, where: {!$0.incFlg}) var consSecResults
    @ObservedResults(BalanceModel.self) var asstsBalResults
    @ObservedResults(BalanceModel.self) var debtBalResults
    // 汎用ビュー
    let generalView = GeneralComponentView()
    // service
    let incConsService = IncomeConsumeService()
    let calendarService = CalendarService()
    let balanceService = BalanceService()
    let incConsSecCatgService = IncConSecCatgService()
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack(alignment: .top) {
                    LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        .ignoresSafeArea()
                        .frame(height: 120)
                    VStack {
                        HStack {
                            Image(systemName: "xmark")
                                .foregroundStyle(.white)
                                .onTapGesture {
                                    self.showFlg = false
                                }
                            Spacer()
                            Image(systemName: "questionmark.circle")
                                .foregroundStyle(.white)
                        }.padding(.horizontal, 20)
                        formTabBar()
                        TabView(selection: $selectForm) {
                            registIncForm()
                                .tag(0)
                            registConsForm()
                                .tag(1)
                            registRepayForm()
                                .tag(2)
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                }
            }
        }.alert(self.assetsFlg ? "資産残高の追加" : "負債残高の追加", isPresented: $addBalAlertFlg) {
            TextField(self.selectIncFlg ? "銀行名、ICカード名" : "銀行名、クレジット名", text: $balanceNm)
            Button("キャンセル") {
                self.addBalAlertFlg = false
            }
            Button("追加") {
                if balanceNm != "" {
//                    self.balanceService.registBalance(balanceNm: balanceNm, assetsFlg: self.assetsFlg)
                    self.selectBalKeys.append("")
                    self.balanceNm = ""
                }
            }
        }.onChange(of: selectForm) {
            withAnimation {
                self.selectIncFlg = self.selectForm == 1 ? false : true
                self.inputAmtDownFlg = false
                self.dateDownFlg = true
                self.isInputAmtFocused = false
                self.isMemoFocused = false
                self.memo = ""
                if self.selectForm == 2 {
                    self.assetsFlg = false
                } else {
                    self.assetsFlg = true
                }
                self.amtBalkeyDic.removeAll()
                self.inputAmtTotal = 0
                selectBalKeys.enumerated().forEach { index, _ in
                    self.selectBalKeys[index] = ""
                }
            }
        }.onChange(of: selectIncFlg) {
            self.incConsSecKey = incConsSecCatgService.getUnCatgSecKey(incFlg: selectIncFlg)
            self.incConsCatgKey = incConsSecCatgService.getIncUnCatgCatgPKey(incFlg: selectIncFlg)
        }
        .onAppear {
            asstsBalResults.forEach { result in
                self.selectBalKeys.append("")
            }
            self.incConsSecKey = incConsSecCatgService.getUnCatgSecKey(incFlg: selectIncFlg)
            self.incConsCatgKey = incConsSecCatgService.getIncUnCatgCatgPKey(incFlg: selectIncFlg)
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
                        Text(LabelsModel.incomeLabel)
                            .onTapGesture {
                                withAnimation {
                                    self.selectForm = 0
                                }
                            }
                        Text(LabelsModel.consumeLabel)
                            .onTapGesture {
                                withAnimation {
                                    self.selectForm = 1
                                }
                            }
                        Text(LabelsModel.debtRepayLabel)
                            .onTapGesture {
                                withAnimation {
                                    self.selectForm = 2
                                }
                            }
                    }.frame(width: local.size.width / 3)
                }.font(.system(size: 14).bold())
                    .foregroundStyle(.white)
                RoundedRectangle(cornerRadius: 25)
                    .fill(.white)
                    .frame(width: local.width / 9 + 30, height: 5)
                    .animation(
                        .spring(), value: selectForm
                    )
                    .offset(x: offsets[selectForm], y: local.maxY)
            }
        }.frame(height: 20)
            .padding(.top, 10)
    }
    
    @ViewBuilder
    func inputForm() -> some View {
        let disAble = self.amtBalkeyDic.count == 0 || incConsSecKey == "" || incConsCatgKey == ""
        VStack {
            GeometryReader { proxy in
                incConsTotalCard(geomProxy: proxy)
            }.frame(height: 110)
                .zIndex(1000)
           ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    Group {
                        if assetsFlg {
                            Text(self.selectIncFlg ? LabelsModel.incSecLabel : LabelsModel.consSecLabel)
                                .font(.caption.bold())
                                .foregroundStyle(Color.changeableText)
                        } else {
                            incConsTab()
                        }
                        ScrollView(.horizontal) {
                            LazyHStack {
                                ForEach(selectIncFlg ? incSecResults : consSecResults, id:\.self) { result in
                                    let colorIndex = result.incConsSecColorIndex
                                    let color = ColorAndImage.colors[colorIndex]
                                    let imageNm = result.incConsSecImage
                                    let secNm = result.incConsSecName
                                    let isSelectSec = result.incConsSecKey == self.incConsSecKey
                                    Menu {
                                        ForEach(result.incConsCatgOfSecList, id: \.self) { catg in
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
                                            generalView.RoundedIcon(radius: 10, color: color,
                                                                    image: imageNm, text: secNm)
                                            .frame(width: isSelectSec ? 50 : 45,
                                                   height:isSelectSec ? 50 : 45)
                                            
                                        }
                                    }.shadow(color: isSelectSec ? .changeableShadow : .clear,
                                             radius: 3, x: 1, y: 1)
                                        .padding(.vertical, 8)
                                }
                            }.padding(.horizontal, 10)
                        }.scrollIndicators(.hidden)
                            .padding(.bottom, 5)
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
                                }
                            VStack(spacing: 5) {
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
                                Image(systemName: "chevron.compact.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 20)
                                    .rotationEffect(.degrees(self.dateDownFlg ? 180 : 0))
                                    .foregroundStyle(Color.changeableText)
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
                        }
                    }.padding(.horizontal, 20)
                    Button(action: {
                        // ▼登録処理
                        incConsService.registIncConsData(inputDic: amtBalkeyDic,
                                                         assetsFlg: assetsFlg,
                                                         incFlg: selectIncFlg,
                                                         incConsSecKey: incConsSecKey,
                                                         incConsCatgKey: incConsCatgKey,
                                                         incConsDate: selectDate, memo: memo)
                        // ▼表示情報を初期化
                        self.amtBalkeyDic.removeAll()
                        self.memo = ""
                        self.inputAmtTotal = 0
                        asstsBalResults.enumerated().forEach { index, result in
                            self.selectBalKeys[index] = ""
                        }
                    }) {
                        ZStack {
                            if !disAble {
                                generalView.GradientCard(colors: accentColors, radius: 10)
                                    .shadow(color: .changeableShadow, radius: 3, x: 3, y: 3)
                                    .frame(height: 50)
                            } else {
                                generalView.GlassBlur(effect: .systemMaterial, radius: 10)
                                    .shadow(color: .changeableShadow, radius: 3, x: 3, y: 3)
                                    .frame(height: 50)
                            }
                            Text(LabelsModel.registLabel)
                                .font(.caption.bold())
                                .foregroundStyle(disAble ? Color.changeableText : Color.white)
                        }
                    }.padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .disabled(disAble)
                }
            }.scrollIndicators(.hidden)
            .padding(.top, 20)
        }.toolbar {
            if isInputAmtFocused {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("キャンセル") {
                        let balKey = selectBalKeys[tapTextFieldIndex]
                        self.amtBalkeyDic[balKey] = 0
                        self.isInputAmtFocused = false
                    }
                    Spacer()
                    Button("完了") {
                        let balKey = selectBalKeys[tapTextFieldIndex]
                        if self.amtBalkeyDic[balKey] == nil {
                            self.amtBalkeyDic[balKey] = 0
                        }
                        self.isInputAmtFocused = false
                    }
                }
            } else if isMemoFocused {
                ToolbarItemGroup(placement: .keyboard) {
                    Button("キャンセル") {
                        self.memo = ""
                        self.isMemoFocused = false
                    }
                    Spacer()
                    Button("完了") {
                        self.isMemoFocused = false
                    }
                }
            }
        }.padding(.top, 10)
    }
    
    @ViewBuilder
    func incConsTab() -> some View {
        ZStack {
            GeometryReader { geometry in
                let width = geometry.size.width / 2
                let midX = geometry.frame(in: .local).midX / 2
                let midY = geometry.frame(in: .local).midY / 2
                generalView.GradientCard(colors: accentColors, radius: 25)
                    .frame(width: width + 2 ,height: 22)
                RoundedRectangle(cornerRadius: 25)
                    .fill(.changeable)
                    .frame(width: width / 2, height: 20)
                    .padding(1)
                    .offset(x: self.selectIncFlg ? 0 : midX)
                HStack(spacing: 0) {
                    Group {
                        Text(LabelsModel.incSecLabel)
                            .foregroundStyle(self.selectIncFlg ? Color.changeableText : Color.white)
                            .onTapGesture {
                                withAnimation {
                                    self.selectIncFlg = true
                                }
                            }
                        Text(LabelsModel.consSecLabel)
                            .foregroundStyle(!self.selectIncFlg ? Color.changeableText : Color.white)
                            .onTapGesture {
                                withAnimation {
                                    self.selectIncFlg = false
                                }
                            }
                            .foregroundStyle(.blue)
                    }.frame(width: width / 2)
                        .offset(y: midY)
                }.font(.caption.bold())
            }
        }.padding(.bottom, 10)
    }
    
    @ViewBuilder
    func incConsTotalCard(geomProxy: GeometryProxy) -> some View {
        let width = geomProxy.frame(in: .local).width - 40
        let height = geomProxy.frame(in: .local).height + 10
        let notAblePullDown = (self.assetsFlg && self.asstsBalResults.isEmpty) ||
                              (!self.assetsFlg && self.debtBalResults.isEmpty)
        let balTotal = balanceService.getBalanceTotal()
        let gapTotal = assetsFlg && selectIncFlg ?
                        balTotal + inputAmtTotal :
                       assetsFlg && !selectIncFlg ?
                        balTotal - inputAmtTotal : balTotal + inputAmtTotal
        let asstsBalCount = self.asstsBalResults.count
        let pullDownRate = asstsBalCount > 5 ? 5 : asstsBalCount <= 2 ? 3 : asstsBalCount
        let rectWidth = width - 40
        let rectHeight = (height * 3) / 4
        let textWidth = (rectWidth - 40)
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.changeable)
                .shadow(color: .changeableShadow, radius: 5)
                .frame(height: self.inputAmtDownFlg ? height * CGFloat(pullDownRate) + 10 : height)
                .padding(.horizontal, self.inputAmtDownFlg ? 10 : 20)
                .onTapGesture {
                    withAnimation {
                        if !notAblePullDown {
                            if self.inputAmtDownFlg {
                                selectBalKeys.forEach { balKey in
                                    if balKey != "" && self.amtBalkeyDic[balKey] == nil {
                                        self.amtBalkeyDic[balKey] = 0
                                    }
                                    self.inputAmtTotal += amtBalkeyDic[balKey] ?? 0
                                }
                            } else {
                                self.inputAmtTotal = 0
                            }
                            self.inputAmtDownFlg.toggle()
                        }
                    }
                }
            VStack(spacing: 0) {
                if self.inputAmtDownFlg {
                    Text(self.assetsFlg ? "資産残高 詳細" :  "負債残高 詳細")
                        .font(.caption.bold())
                        .foregroundStyle(Color.changeableText)
                        .frame(maxWidth: width - 40, alignment: .leading)
                        .padding(.vertical, 10)
                        .padding(.top, 10)
                    ScrollView {
                        LazyVStack {
                            ForEach(self.assetsFlg ? asstsBalResults.indices :
                                                     debtBalResults.indices, id: \.self) { index in
                                let result = assetsFlg ? asstsBalResults[index] : debtBalResults[index]
                                let balNm = result.balanceNm
                                let balAmt = result.balanceAmt
                                let balKey = result.balanceKey
                                let haveBalKey = selectBalKeys[index] == balKey
                                let eachAmt = assetsFlg && selectIncFlg ?
                                                balAmt + (amtBalkeyDic[balKey] ?? 0) :
                                              assetsFlg && !selectIncFlg ?
                                                balAmt - (amtBalkeyDic[balKey] ?? 0) :
                                                balAmt + (amtBalkeyDic[balKey] ?? 0)
                                let isColorChange = balAmt != eachAmt
                                ZStack {
                                    generalView.GlassBlur(effect: haveBalKey ?
                                        .systemMaterial :  .systemUltraThinMaterial, radius: 10)
                                        .frame(width: rectWidth, height: haveBalKey ?
                                           rectHeight + 20 : rectHeight)
                                        .shadow(color: haveBalKey ? .changeableShadow : .clear,
                                                radius: 3, x: 3, y: 3)
                                        .padding(.vertical, haveBalKey ? 10 : 0)
                                    if !haveBalKey {
                                        HStack(spacing: 0) {
                                            VStack(alignment: .leading) {
                                                Text(balNm)
                                                    .font(.caption.bold())
                                                Text("¥\(balAmt)")
                                                    .font(.system(.callout, design: .rounded))
                                            }.frame(width: textWidth / 2 - 20, alignment: .leading)
                                                .foregroundStyle(Color.changeableText)
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                            Rectangle().frame(width: 1, height: 40)
                                                .padding(.horizontal, 20)
                                                .foregroundStyle(Color.changeableText)
                                            Button(action: {
                                                withAnimation {
                                                    self.amtBalkeyDic[balKey] = 0
                                                    self.selectBalKeys[index] = balKey
                                                }
                                            }) {
                                                ZStack {
                                                    generalView.GradientCard(colors: accentColors, radius: 6)
                                                        .shadow(color: .changeableShadow, radius: 3)
                                                    HStack {
                                                        Image(systemName: "square.and.pencil")
                                                            .font(.callout.bold())
                                                        Text(assetsFlg && selectIncFlg ? "収入額入力" :
                                                                assetsFlg && !selectIncFlg ?
                                                             "支出額入力" : "負債額入力")
                                                            .font(.caption2.bold())
                                                    }.foregroundStyle(.white)
                                                }.frame(width: textWidth / 2 - 20, height: height / 2 - 10)
                                            }
                                        }
                                    } else {
                                        VStack(spacing: 5) {
                                            HStack(spacing: 0) {
                                                Text(balNm)
                                                    .font(.caption.bold())
                                                    .frame(maxWidth: textWidth / 2 - 20, alignment: .leading)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.5)
                                                Spacer()
                                                Button(action: {
                                                    withAnimation {
                                                        // ▼animation後に返すものがなくwarningが発生するため
                                                        if self.amtBalkeyDic[balKey] != nil {
                                                            _ = self.amtBalkeyDic.removeValue(forKey: balKey)
                                                        }
                                                        self.selectBalKeys[index] = ""
                                                    }
                                                }) {
                                                    Text("キャンセル")
                                                        .font(.caption.bold())
                                                        .foregroundStyle(accentColors.last ?? .changeableText)
                                                        .shadow(radius: 10)
                                                }.frame(maxWidth: textWidth / 2 - 20, alignment: .trailing)
                                            }.frame(width: textWidth)
                                            HStack(spacing: 0) {
                                                Text("¥\(balAmt)")
                                                    .font(.system(.callout, design: .rounded))
                                                    .frame(maxWidth: textWidth / 2 - 20,
                                                           alignment: .leading)
                                                Image(systemName: "arrowshape.right.fill")
                                                    .padding(.horizontal, 10)
                                                Text("¥\(eachAmt)")
                                                    .font(.system(.callout, design: .rounded, weight: .bold))
                                                    .foregroundStyle(
                                                        assetsFlg && selectIncFlg ?
                                                        isColorChange ? .blue : .changeableText :
                                                        isColorChange ? .red : .changeableText)
                                                    .frame(maxWidth: textWidth / 2 - 20,
                                                           alignment: .trailing)
                                            }.lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                            Rectangle().frame(width: textWidth, height: 1)
                                                .padding(.horizontal, 20)
                                                .foregroundStyle(Color.changeableText)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .foregroundStyle(Color.changeable)
                                                    .frame(width: textWidth, height: 30)
                                                TextField("金額を入力", value: $amtBalkeyDic[balKey], format: .number)
                                                    .focused($isInputAmtFocused)
                                                    .font(.system(.callout, design: .rounded, weight: .bold))
                                                    .padding(.horizontal, 10)
                                                    .foregroundStyle(
                                                       assetsFlg && selectIncFlg ? .blue : .red
                                                    )
                                                    .frame(width: textWidth, height: 15)
                                                    .keyboardType(.numberPad)
                                                    .multilineTextAlignment(.trailing)
                                                    .onTapGesture {
                                                        if self.amtBalkeyDic[balKey] == 0 {
                                                            self.amtBalkeyDic[balKey] = nil
                                                        }
                                                        self.tapTextFieldIndex = index
                                                    }
                                            }
                                        }.foregroundStyle(Color.changeableText)
                                    }
                                }
                            }
                            Button(action: {
                                self.addBalAlertFlg = true
                            }) {
                                ZStack {
                                    generalView.GlassBlur(effect: .systemMaterial, radius: 5)
                                        .frame(width: 100, height: 30)
                                        .shadow(color: .changeableShadow, radius: 3, x: 3, y: 3)
                                    HStack {
                                        Text("残高名の追加")
                                        Image(systemName: "plus")
                                    }.font(.caption2.bold())
                                        .foregroundStyle(accentColors.last ?? .changeableText)
                                }
                            }
                        }.padding(.vertical, 5)
                    }.frame(height: height * CGFloat(pullDownRate) - 50)
                        .scrollIndicators(.hidden)
                } else {
                    if notAblePullDown {
                        VStack {
                            Text(self.selectIncFlg ? "資産残高が存在しません。" : "負債残高が存在しません。")
                                .font(.caption.bold())
                                .foregroundStyle(Color.changeableText)
                            Button(action: {
                                self.addBalAlertFlg = true
                            }) {
                                ZStack {
                                    generalView.GlassBlur(effect: .systemMaterial, radius: 5)
                                        .frame(width: 100, height: 30)
                                        .shadow(color: .changeableShadow, radius: 3, x: 3, y: 3)
                                    HStack {
                                        Text("残高名の追加")
                                        Image(systemName: "plus")
                                    }.font(.caption2.bold())
                                        .foregroundStyle(accentColors.last ?? .changeableText)
                                }
                            }
                        }
                    } else {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(self.assetsFlg ? "資産残高合計" : "負債残高合計")
                                    .font(.caption2.bold())
                                Text("¥\(balTotal)")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .font(.system(.callout, design: .rounded, weight: .bold))
                            }.frame(width: width / 4)
                                .foregroundStyle(Color.changeableText)
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.changeableText)
                                .frame(width: 1, height: 50)
                                .padding(.horizontal, 5)
                            VStack(alignment: .leading) {
                                Text(LabelsModel.formInputTotalLabels[selectForm])
                                    .font(.caption2.bold())
                                    .foregroundStyle(Color.changeableText)
                                Text("¥\(self.inputAmtTotal)")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(
                                        self.assetsFlg && self.selectIncFlg && inputAmtTotal > 0 ?
                                            .blue : inputAmtTotal > 0 ? .red : .changeableText
                                    )
                                    .font(.system(.callout, design: .rounded, weight: .bold))
                            }.frame(width: width / 4)
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.changeableText)
                                .frame(width: 1, height: 50)
                                .padding(.horizontal, 5)
                            VStack(alignment: .leading) {
                                Text("差額")
                                    .font(.caption2.bold())
                                    .foregroundStyle(Color.changeableText)
                                Text("¥\(gapTotal)")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .foregroundStyle(
                                        assetsFlg && (gapTotal > balTotal) ? .blue :
                                        (gapTotal < balTotal || gapTotal < 0) ||
                                        (!assetsFlg && gapTotal != 0) ? .red : Color.changeableText
                                    )
                                    .font(.system(.callout, design: .rounded, weight: .bold))
                            }.frame(width: width / 4)
                        }
                    }
                }
                if !notAblePullDown {
                    Image(systemName: "chevron.compact.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: self.inputAmtDownFlg ? 30 : 10)
                        .padding(.top, self.inputAmtDownFlg ? 5 : 10)
                        .foregroundStyle(Color.changeableText)
                        .rotationEffect(.degrees(self.inputAmtDownFlg ? 180 : 0))
                }
            }
        }
    }
    // 収入登録
    @ViewBuilder
    func registIncForm() -> some View {
        inputForm()
    }
    // 支出登録
    @ViewBuilder
    func registConsForm() -> some View {
        inputForm()
    }
    // 返済
    @ViewBuilder
    func registRepayForm() -> some View {
        inputForm()
    }
}

#Preview {
    @State var showFlg = true
    @State var accentColors: [Color] = [.purple, .indigo]
    return RegistIncConsFormView(showFlg: $showFlg, accentColors: accentColors)
}

//#Preview {
//    ContentView()
//}
