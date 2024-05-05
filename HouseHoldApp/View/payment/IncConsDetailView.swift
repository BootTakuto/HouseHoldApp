//
//  IncConsDetailView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/04/12.
//

import SwiftUI
import RealmSwift

struct IncConsDetailView: View {
    // init biding
    var accentColors: [Color]
    @Binding var detailPageFlg: Bool
    @Binding var incConsObject: IncomeConsumeModel
    @Binding var incConsDic: [String: Results<IncomeConsumeModel>]
    // form
    @State private var selectDate = Date()
    @State private var memo = ""
    @State private var incConsSecKey = ""
    @State private var incConsCatgKey = ""
    // 操作
    @State private var editFlg = false
    @State private var dateDownFlg = false
    @State private var amtCardDownFlg = false
    @FocusState var isMemoFocused
    @State private var alertFlg = false
    // service
    let incConsService = IncomeConsumeService()
    let balService = BalanceService()
    // view
    let generalView = GeneralComponentView()
    let navigationHeight: CGFloat = 100
    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack(alignment: .top) {
                    LinearGradient(colors: accentColors,
                                   startPoint: .topLeading, endPoint: .topTrailing)
                    .ignoresSafeArea()
                    .frame(height: navigationHeight)
                    VStack {
                        NavigationHeader()
                        DetailForm()
                            .padding(.top, 20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            self.incConsSecKey = incConsObject.incConsSecKey
            self.incConsCatgKey = incConsObject.incConsCatgKey
            self.selectDate = incConsService.convertStrToDate(dateStr: incConsObject.incConsDate,
                                                        format: "yyyyMMdd")
            self.memo = incConsObject.memo
        }.alert("収支情報の削除", isPresented: $alertFlg) {
            Button("削除",role: .destructive) {
                incConsService.deleteIncConsData(incConsKey: self.incConsObject.incConsKey)
                self.incConsDic = incConsService.getIncConsPerDate(selectDate: Date())
                self.detailPageFlg = false
                // ▼ 削除されたオブジェクトを参照して落ちるため
                self.incConsObject = IncomeConsumeModel()
            }
            Button("キャンセル", role: .cancel) {
                self.alertFlg = false
            }
        } message: {
            Text("⚠️この収支情報は完全に失われます。\nよろしいですか？")
        }
    }
    
    @ViewBuilder
    func NavigationHeader() -> some View {
        HStack {
            Button(action: {
                self.detailPageFlg = false
            }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
            }
            Spacer()
            if !editFlg {
                Menu {
                    Button(action: {
                        withAnimation {
                            self.editFlg = true
                        }
                    }) {
                        Text("編集")
                        Image(systemName: "square.and.pencil")
                    }
                    Button(role: .destructive, action: {
                        withAnimation {
                            self.alertFlg = true
                        }
                    }) {
                        Text("削除")
                        Image(systemName: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                }
            } else {
                Button(action: {
                    withAnimation {
                        self.editFlg = false
                        self.dateDownFlg = false
                        self.incConsSecKey = incConsObject.incConsSecKey
                        self.incConsCatgKey = incConsObject.incConsCatgKey
                        self.selectDate = incConsService.convertStrToDate(dateStr: incConsObject.incConsDate,
                                                                    format: "yyyyMMdd")
                        self.memo = incConsObject.memo
                    }
                }) {
                    Text("キャンセル")
                        .foregroundStyle(.white)
                        .fontWeight(.bold)
                }
            }
        }.padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func AmtCard(incFlg: Bool) -> some View {
        let balList = incConsObject.balanceKeyList
        let amtList = incConsObject.incConsAmtList
        let rectScaleAmt: CGFloat = balList.count > 3 ? 3 : CGFloat(balList.count)
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(.changeable)
                .shadow(color: .changeableShadow, radius: 5)
                .frame(height: self.amtCardDownFlg ?  navigationHeight * rectScaleAmt + 50 :
                        navigationHeight)
                .padding(.horizontal, self.amtCardDownFlg ? 10 : 20)
                .onTapGesture {
                    withAnimation {
                        self.amtCardDownFlg.toggle()
                    }
                }
            GeometryReader {
                let size = $0.size
                VStack {
                    if !amtCardDownFlg {
                        HStack {
                            Text(incFlg ? "収 入 額" : "支 出 額")
                                .foregroundStyle(Color.changeableText)
                                .fontWeight(.bold)
                            Spacer()
                            Text("¥\(incConsObject.incConsAmtTotal)")
                                .foregroundStyle(incFlg ? .blue : .red)
                                .font(.system(.title2, design: .rounded, weight: .bold))
                                .frame(width: (size.width - 40) / 2, alignment: .trailing)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }.frame(maxHeight: .infinity, alignment: .center)
                    } else {
                        GeometryReader {
                            let width = $0.size.width
                            VStack {
                                Text("収入額　詳細")
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.changeableText)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ScrollView {
                                    VStack {
                                        ForEach(balList.indices, id: \.self) { index in
                                            let key = balList[index]
                                            let balObj = balService.getBalanceResult(balanceKey: key)
                                            let amt = amtList[index]
                                            ZStack {
                                                generalView.GlassBlur(effect: .systemUltraThinMaterial,
                                                                      radius: 10)
                                                .frame(height: 80)
                                                HStack(spacing: 0) {
                                                    if !editFlg {
                                                        Text(balObj.balanceNm)
                                                            .font(.caption.bold())
                                                            .foregroundStyle(Color.changeableText)
                                                            .frame(maxWidth: (width - 20) / 2, alignment: .leading)
                                                        Text("¥\(amt)")
                                                            .font(.system(.subheadline, design: .rounded, weight: .bold))
                                                            .foregroundStyle(incFlg ? .blue : .red)
                                                            .frame(width: (width - 20) / 2, alignment: .trailing)
                                                            .lineLimit(1)
                                                            .minimumScaleFactor(0.5)
                                                    } else {
                                                        VStack(alignment: .leading) {
                                                            Text(balObj.balanceNm)
                                                                .font(.caption.bold())
                                                                .foregroundStyle(Color.changeableText)
                                                            Text("¥\(amt)")
                                                                .font(.system(.subheadline, design: .rounded, weight: .bold))
                                                                .foregroundStyle(incFlg ? .blue : .red)
                                                                .lineLimit(1)
                                                                .minimumScaleFactor(0.5)
                                                        }.frame(maxWidth: (width - 40) / 2, alignment: .leading)
                                                        generalView.Bar()
                                                            .frame(height: 50)
                                                            .padding(.horizontal, 5)
                                                        Button(action: {
                                                            
                                                        }) {
                                                            ZStack {
                                                                generalView.GradientCard(colors: accentColors,
                                                                                         radius: 6)
                                                                .frame(width: width / 2 - 30)
                                                                HStack {
                                                                    Image(systemName: "square.and.pencil")
                                                                        .font(.callout.bold())
                                                                    Text("編集")
                                                                        .font(.caption.bold())
                                                                }.foregroundStyle(.white)
                                                            }
                                                        }.frame(width: (width - 40) / 2, height: 50,
                                                                alignment: .trailing)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }.scrollIndicators(.hidden)
                            }
                        }
                    }
                    Image(systemName: "chevron.compact.down")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 10)
                        .rotationEffect(.degrees(self.amtCardDownFlg ? 180 : 0))
                        .foregroundStyle(Color.changeableText)
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
            }
        }
    }
    
    @ViewBuilder
    func DetailForm() -> some View {
        let incFlg = incConsObject.incFlg
        let disAble = false
        @ObservedResults(IncConsSectionModel.self, where: {$0.incFlg == incFlg}) var incConsSecResults
        VStack {
            GeometryReader { _ in
                AmtCard(incFlg: incFlg)
            }.frame(height: navigationHeight)
                .zIndex(1000)
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    Group {
                        Text(incFlg ? LabelsModel.incSecLabel : LabelsModel.consSecLabel)
                            .font(.caption.bold())
                            .foregroundStyle(Color.changeableText)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(incConsSecResults, id: \.self) { result in
                                    let isSelectSec = result.incConsSecKey == self.incConsSecKey
                                    let colorIndex = result.incConsSecColorIndex
                                    let color = isSelectSec ? ColorAndImage.colors[colorIndex] :
                                    editFlg ? ColorAndImage.colors[colorIndex]: Color(uiColor: .systemGray5)
                                    let imageNm = result.incConsSecImage
                                    let secNm = result.incConsSecName
                                    Menu {
                                        ForEach(result.incConsCatgOfSecList, id: \.self) { catg in
                                            let isSelectCatg = catg.incConsCatgKey ==  self.incConsCatgKey
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
                                            }.disabled(!self.editFlg)
                                        }
                                    } label: {
                                        ZStack {
                                            generalView.RoundedIcon(radius: 10, color: color,
                                                                    image: imageNm, text: secNm)
                                            .frame(width: isSelectSec ? 50 : 45,
                                                   height:isSelectSec ? 50 : 45)
                                            
                                        }.shadow(color: isSelectSec ? .changeableShadow : .clear,
                                                 radius: 3, x: 1, y: 1)
                                        .padding(.vertical, 8)
                                    }.disabled(!isSelectSec && !self.editFlg)
                                }
                            }
                        }.padding(.horizontal, 10)
                            .scrollIndicators(.hidden)
                        Text(LabelsModel.dateLabel)
                            .font(.caption.bold())
                            .foregroundStyle(Color.changeableText)
                        ZStack {
                            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                                .frame(height: self.dateDownFlg ? 350 : 60)
                                .onTapGesture {
                                    if editFlg {
                                        withAnimation {
                                            self.dateDownFlg.toggle()
                                        }
                                    }
                                }
                            VStack(spacing: 5) {
                                if dateDownFlg && editFlg {
                                    DatePicker("", selection: $selectDate, displayedComponents: .date)
                                        .datePickerStyle(.graphical)
                                        .frame(height: 300)
                                        .padding(.horizontal, 10)
                                        .tint(accentColors.last!)
                                        .environment(\.locale, Locale(identifier: "ja_JP"))
                                } else {
                                    Text(incConsService.getStringDate(date: selectDate,
                                                                      format: "yyyy年MM月dd日"))
                                    .foregroundStyle(Color.changeableText)
                                    .font(.callout.bold())
                                }
                                if editFlg {
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
                                .disabled(!editFlg)
                        }
                    }.padding(.horizontal, 20)
                    if editFlg {
                        Button(action: {
                            
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
                            .disabled(editFlg)
                    }
                }
            }.padding(.top, 20)
        }.toolbar {
            if isMemoFocused {
                ToolbarItem(placement: .keyboard) {
                    HStack {
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
            }
        }
    }
}

#Preview {
    ContentView()
}
