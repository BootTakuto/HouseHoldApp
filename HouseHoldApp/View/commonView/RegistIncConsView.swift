//
//  RegistInConsView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/01/22.
//

import SwiftUI
import RealmSwift

struct RegistIncConsView: View {
    /* 親情報 */
    var accentColors: [Color]
    @State var balanceKey = ""
    // モーダル表示フラグ
    @Binding var registIncConsFlg: Bool
    // 残高合計、収入合計金額、支出合計金額
    @Binding var asstsbalTotal: Int
    @Binding var incAmtTotal: Int
    @Binding var consAmtTotal: Int
    /* form情報 */
    //登録データ
    @State var incConsAmt = "0"
    @Binding var date: Date
    @State var memo = ""
    @State var selectedInc = true
    @State var incConsCatgKey = IncConSecCatgService().getIncUnCatgCatgPKey(incFlg: true)
    @FocusState var isAmtFocused: Bool
    @FocusState var isMemoFocused: Bool
    // 収入・支出項目表示ラベル用
    @State var selectSecIndex = 0
    // 収入・支出項目登録関連
    @State var registIncConsSecFlg = false
    @State var editSecFlg = false
    @State var incConsSecKey = ""
    @State var registIncConsCatgFlg = false
    @State var incConsCatgNm = ""
    @State var registDebtFlg = false
    /* result */
    @ObservedResults(BalanceModel.self, where: {$0.assetsFlg}) var assetsBalResults
    @ObservedResults(BalanceModel.self, where: {!$0.assetsFlg}) var debtBalResults
    /* sevice */
    let balService = BalanceService()
    let iCSecCatgService = IncConSecCatgService()
    let incConsService = IncomeConsumeService()
    /** view関連 */
    // picker
    @State var selectIndex = 0
    @State var selectBalIndex = 0
    // カレンダー
    @State var datePickerFlg = false
    // view表示用
    let screen = UIScreen.main.bounds
    let generalView = GeneralComponentView()
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Text(LabelsModel.incConsRegistLabel)
                            .font(.callout.bold())
                            .frame(alignment: .leading)
                        Button(action: {
                            
                        }) {
                            Image(systemName: "questionmark.circle")
                        }
                        Spacer()
                        Button(action: {
                            self.registIncConsFlg = false
                        }) {
                            Image(systemName: "xmark.circle")
                        }
                    }.foregroundStyle(Color.changeableText)
                        .frame(width: screen.width - 80)
                        .padding(.top, 20)
                    ZStack {
//                        generalView.GlassGradient(color: accentColors[0],
//                                                  w: screen.width - 30,
//                                                  h: screen.height - 150)
                        InputForm()
                    }.frame(width: screen.width - 30, height: screen.height - 150)
                }
            }.navigationDestination(isPresented: $registIncConsSecFlg) {
                RegistIncConsSecPage(accentColors: accentColors,
                                     registIncConsFlg: $registIncConsFlg,
                                     registIncConsSecFlg: $registIncConsSecFlg,
                                     selectedInc: $selectedInc,
                                     editSecFlg: editSecFlg,
                                     incConsSecKey: incConsSecKey)
            }
            .overlay {
                if self.datePickerFlg {
                    ZStack {
                        UIGlassCard(effect: .systemUltraThinMaterial)
                        generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 15)
                            .shadow(color: .changeableShadow, radius: 10, x: 5, y: 5)
                            .frame(width: 350, height: 400)
                        VStack(spacing: 0) {
                            HStack {
                                Spacer(minLength: 0)
                                Button(action: {
                                    withAnimation(.easeInOut) {
                                        self.datePickerFlg = false
                                    }
                                }) {
                                    Image(systemName: "xmark.circle")
                                }.foregroundStyle(Color.changeableText)
                            }
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .environment(\.locale, Locale(identifier: "ja_JP"))
                        }.frame(width: 300, height: 400)
                    }.ignoresSafeArea()
                }
            }
            .onChange(of: isAmtFocused) {
                if isAmtFocused && incConsAmt == "0" {
                    self.incConsAmt = ""
                }
            }
            .onChange(of: self.selectedInc) {
                self.selectSecIndex = 0
                if !selectedInc {
                    self.incConsCatgKey = iCSecCatgService.getIncUnCatgCatgPKey(incFlg: false)
                } else {
                    self.incConsCatgKey = iCSecCatgService.getIncUnCatgCatgPKey(incFlg: true)
                }
            }
            .onChange(of: date) {
                withAnimation(.easeInOut) {
                    self.datePickerFlg = false
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Button("キャンセル") {
                            self.isAmtFocused = false
                            self.isMemoFocused = false
                            self.incConsAmt = "0"
                            self.memo = ""
                        }
                        Spacer()
                        Button("完了") {
                            self.isAmtFocused = false
                            self.isMemoFocused = false
                            if incConsAmt == "" {
                                self.incConsAmt = "0"
                            }
                        }
                   }
                }
            }
        }
    }
    
    @ViewBuilder
    func BalanceCard(nm: String, amt: Int, isSelect: Bool) -> some View {
        ZStack {
            if isSelect {
//                RoundedRectangle(cornerRadius: 15)
//                    .fill(.changeable)
                UIGlassCard(effect: .systemMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(color: .changeableShadow, radius: 3, x: 3, y: 3)
            } else {
                generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 15)
            }
            VStack {
                Group {
                    Text(nm)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("¥\(amt)")
                        .font(.system(.callout, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }.lineLimit(1)
                    .minimumScaleFactor(0.5)
            }.foregroundStyle(Color.changeableText)
                .padding(.horizontal, 10)
        }
    }
    
    @ViewBuilder
    func incConsSelectPicker() -> some View {
        let labels = ["収入", "支出"]
        GeometryReader {geometry in
            let size = geometry.size
            let midX = geometry.frame(in: .local).midX
            ZStack {
                UIGlassCard(effect: .systemMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                GeometryReader { _ in
                    generalView.GradientCard(colors: accentColors, radius: 10)
                        .frame(width: size.width / 2, height: size.height)
                        .shadow(color: .changeableShadow, radius: 2, x: 2, y: 2)
                        .offset(x: selectedInc ? 0 : midX)
                }
                HStack(spacing: 0) {
                    ForEach(0 ..< labels.count, id: \.self) { index in
                        Text(labels[index])
                            .font(.caption.bold())
                            .frame(width: size.width / 2)
                            .foregroundStyle(selectIndex == index ? .white : Color.changeableText)
                            .onTapGesture {
                                withAnimation(
                                    .interpolatingSpring(
                                        mass: 1.0,
                                        stiffness: 240.0,
                                        damping: 18.0,
                                        initialVelocity: 2.0
                                    )) {
                                        self.selectedInc = index == 0 ? true : false
                                        self.selectIndex = index
                                    }
                            }
                    }
                }
            }
        }.frame(width: screen.width / 2, height: 30)
    }
    
    // トグルボタン
    func IncreDebtToggle() -> some View {
        GeometryReader { geometry in
            let local = geometry.frame(in: .local)
            let midX = local.midX
            ZStack {
                if !registDebtFlg {
                    UIGlassCard(effect: .systemMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                } else {
                    LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                GeometryReader { localGeom in
                   Circle()
                        .fill(.white)
                        .frame(width: local.width / 2)
                        .offset(x: registDebtFlg ? 0 : midX)
                }
            }.onTapGesture {
                withAnimation(.easeInOut) {
                    self.registDebtFlg.toggle()
                }
            }
        }
    }
    
    // フォーム
    @ViewBuilder
    func InputForm() -> some View {
        // result
        @ObservedResults(IncConsSectionModel.self, where: {$0.incFlg == selectedInc}) var incConsSecResults
        let formWidth = screen.width - 60
        ScrollView {
            VStack(spacing: 5) {
                incConsSelectPicker()
                    .padding(.vertical, 10)
                if !selectedInc {
                    HStack {
                        Text("負債の増加として登録")
                            .font(.caption.bold())
                            .foregroundStyle(Color.changeableText)
                        IncreDebtToggle()
                            .frame(width: 40)
                    }.frame(width: formWidth, height: 20, alignment: .trailing)
                        .padding(.vertical, 5)
                }
                Text(LabelsModel.amtLabel)
                    .font(.caption.bold())
                    .foregroundStyle(Color.changeableText)
                    .frame(maxWidth: formWidth, alignment: .leading)
                TextField(LabelsModel.inputAmtLabel, text: $incConsAmt)
                    .font(.system(.callout, design: .rounded))
                    .foregroundStyle(Color.changeableText)
                    .padding()
                    .frame(width: formWidth, height: 50)
                    .keyboardType(.numberPad)
                    .background(
                        UIGlassCard(effect: .systemUltraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    )
                    .multilineTextAlignment(.trailing)
                    .focused($isAmtFocused)
                VStack(spacing: 5){
                    HStack {
                        Text(LabelsModel.dateLabel)
                            .font(.caption)
                            .frame(maxWidth: formWidth, alignment: .leading)
                    }.frame(width: formWidth)
                    Button(action: {
                        withAnimation(.easeInOut) {
                            self.datePickerFlg.toggle()
                        }
                    }) {
                        ZStack {
                            let dateStr = incConsService.getStringDate(date: date, format: "yyyy年MM月dd日")
                            UIGlassCard(effect: .systemUltraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                            Text(dateStr)
                                .font(.system(.callout, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.changeableText)
                        }.frame(width: formWidth, height: 50)
                    }
                }.padding(.vertical, 10)
                Text(self.selectedInc ? LabelsModel.incSecLabel :
                        LabelsModel.consSecLabel)
                .font(.caption.bold())
                .foregroundStyle(Color.changeableText)
                .frame(width: formWidth, alignment: .leading)
                GeometryReader { geometry in
                    let height = geometry.frame(in: .local).height
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 0) {
                            let balanceResults = registDebtFlg ? debtBalResults : assetsBalResults
                            ForEach(0 ..< balanceResults.count, id: \.self) { index in
                                let balNm = balanceResults[index].balanceNm
                                let balAmt = balanceResults[index].balanceAmt
                                BalanceCard(nm: balNm, amt: balAmt,
                                            isSelect: index == self.selectBalIndex)
                                    .padding(.horizontal, 5)
                                    .frame(width: formWidth / 3, height: height - 20)
                                    .onTapGesture {
                                        withAnimation(.easeInOut) {
                                            self.balanceKey = balanceResults[index].balanceKey
                                            self.selectBalIndex = index
                                        }
                                    }
                                    .offset(y: index == self.selectBalIndex ? -5 : 0)
                            }
                            Button(action: {
                                // 残高追加
                            }) {
                                ZStack {
                                    generalView.GlassBlur(effect: .systemUltraThinMaterial,
                                                          radius: 10)
                                    Image(systemName: "plus")
                                        .foregroundStyle(Color.changeableText)
                                }
                            }.frame(width: (formWidth / 3) / 2)
                        }.padding(.vertical, 10)
                    }.scrollIndicators(.hidden)
                }.frame(width: formWidth, height: 100)
                Text(self.selectedInc ? LabelsModel.incSecLabel : LabelsModel.consSecLabel)
                    .font(.caption)
                    .frame(maxWidth: formWidth, alignment: .leading)
                GeometryReader { geometry in
                    // ▼サイズ
                    let localWidth = geometry.frame(in: .local).width
                    let rectWidth = localWidth / 5 - 10
                    ScrollView(.horizontal) {
                        VStack {
                            LazyHStack(spacing: 0) {
                                ForEach(0 ..< incConsSecResults.count, id:\.self) { secIndex in
                                    // ▼取得した項目オブジェクト
                                    let secResult = incConsSecResults[secIndex]
                                    Menu {
                                        Section {
                                            ForEach(0 ..< secResult.incConsCatgOfSecList.count, id:\.self) { catgIndex in
                                                // ▼取得したカテゴリーオブジェクト
                                                let catgResult = secResult.incConsCatgOfSecList[catgIndex].freeze()
                                                Button(action: {
                                                    self.incConsSecKey = catgResult.incConsSecKey
                                                    self.incConsCatgKey = catgResult.incConsCatgKey
                                                    selectSecIndex = secIndex
                                                }) {
                                                    Text("\(catgResult.incConsCatgNm)")
                                                }
                                            }
                                        } header:  {
                                            Text("カテゴリー")
                                        }
                                        Button(action: {
                                            self.editSecFlg = true
                                            self.incConsSecKey = secResult.incConsSecKey
                                            self.registIncConsSecFlg = true
                                        }) {
                                            HStack {
                                                Label("編集", systemImage: "chevron.right")
                                            }
                                        }
                                    }label: {
                                        // ▼ラベル表示用
                                        let colorIndex = secResult.incConsSecColorIndex
                                        let imageNm = secResult.incConsSecImage
                                        // ▼条件によって表示するラベル名を変更
                                        let labelNm = self.incConsCatgKey != "" && self.selectSecIndex == secIndex ?
                                        iCSecCatgService.getCatgNm(catgKey: self.incConsCatgKey) :
                                        secResult.incConsSecName
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(ColorAndImage.colors[colorIndex])
                                                .stroke(
                                                    .linearGradient(colors: [.changeableGlassStroke,
                                                                             .gray],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing)
                                                )
                                                .frame(width: rectWidth, height: rectWidth)
                                                .shadow(color: self.selectSecIndex == secIndex ?.changeableShadow : .clear,
                                                        radius: 3, x: 3, y: 3)
                                            VStack(spacing: 0) {
                                                Group {
                                                    Image(systemName: imageNm)
                                                        .foregroundStyle(.white)
                                                    Text("\(labelNm)")
                                                        .font(.caption)
                                                        .foregroundStyle(.white)
                                                        .frame(width: rectWidth - 5)
                                                        .lineLimit(1)
                                                        .minimumScaleFactor(0.5)
                                                }.fontWeight(.bold)
                                            }
                                        }.padding(5)
                                    }.offset(y: self.selectSecIndex == secIndex ? -5 : 0)
                                }
                                Button(action: {
                                    self.editSecFlg = false
                                    self.registIncConsSecFlg = true
                                    self.incConsSecKey = ""
                                }) {
                                    ZStack {
                                        generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                                        HStack(spacing: 5) {
                                            Text(LabelsModel.addLabel)
                                            Image(systemName: "chevron.right")
                                        }.foregroundStyle(Color.changeableText)
                                            .font(.caption.bold())
                                    }.frame(width: rectWidth, height: rectWidth)
                                }.padding(.leading, 5)
                            }
                        }
                    }.scrollIndicators(.hidden)
                }.frame(width: formWidth, height: formWidth / 5 + 15)
                Text(LabelsModel.memoLabel)
                    .font(.caption)
                    .frame(maxWidth: formWidth, alignment: .leading)
                TextEditor(text: $memo)
                    .font(.callout)
                    .scrollContentBackground(.hidden)
                    .background(
                        UIGlassCard(effect: .systemUltraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    )
                    .frame(width: formWidth, height: 120)
                    .foregroundStyle(Color.changeableText)
                    .focused($isMemoFocused)
                // ▼非活性条件
                let isDisabled = assetsBalResults.isEmpty || debtBalResults.isEmpty || Int(self.incConsAmt) == nil || incConsSecResults.isEmpty
                Button(action: {
                    if balanceKey != "" {
                        if self.incConsCatgKey == "" {
                            self.incConsCatgKey = incConsSecResults[0].incConsCatgOfSecList[0].incConsCatgKey
                        }
                        let registAmt = Int(self.incConsAmt) ?? 0
                        incConsService.registIncConsData(balanceKey: self.balanceKey,
                                                         incFlg: self.selectedInc,
                                                         incConsSecKey: self.incConsSecKey,
                                                         incConsCatgKey: self.incConsCatgKey,
                                                         incConsAmt: registAmt,
                                                         incConsDate: self.date,
                                                         memo: self.memo)
                    }
                    // 残高合計を再取得
//                    self.asstsbalTotal = balService.getAsstsBalTotal(assetsFlg: true)
                    self.incAmtTotal = incConsService.getIncOrConsAmtTotal(date: date, incFlg: true)
                    self.consAmtTotal = incConsService.getIncOrConsAmtTotal(date: date, incFlg: false)
                    self.incConsAmt = "0"
                }) {
                    ZStack {
                        generalView.RegistButton(colors: accentColors,
                                                 isDisable: isDisabled, w: formWidth, h: 60,
                                                 radius: 15)
                        .shadow(color: .changeableShadow, radius: 3, x: 3, y: 3)
                        Text(LabelsModel.registLabel)
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }.frame(width: formWidth, height: 50)
                .disabled(isDisabled)
                .padding(.top, 20)
            }.frame(width: formWidth + 30)
        }.scrollIndicators(.hidden)
    }
}

#Preview {
    @State var registIncConFlg = false
    @State var asstsbalTotal = 0
    @State var incAmtTotal = IncomeConsumeService().getIncOrConsAmtTotal(date: Date(), incFlg: true)
    @State var consAmtTotal = IncomeConsumeService().getIncOrConsAmtTotal(date: Date(), incFlg: false)
    @State var date = Date()
    @ObservedResults(BalanceModel.self) var balanceResults
    return RegistIncConsView(accentColors: [.purple, .indigo],
                             balanceKey: balanceResults.isEmpty ? "" : balanceResults[0].balanceKey,
                             registIncConsFlg: $registIncConFlg,
                             asstsbalTotal: $asstsbalTotal,
                             incAmtTotal: $incAmtTotal,
                             consAmtTotal: $consAmtTotal,
                             date: $date)
}

//#Preview {
//    ContentView()
//}
