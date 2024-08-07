//
//  BudgetView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/07/09.
//

import SwiftUI

struct BudgetView: View {
    var accentColors: [Color]
    @Binding var budgetDestFlg: Bool
    /* data */
    @State var selectDate = Date()
    @State var popUpFlg = false
    @State var popUpStatus: PopUpStatus = .addBudget
    @State var budgetObj = BudgetService().getBudgetInfo(selectDate: Date())
    @State var inputBudgetAmt = ""
    /* view */
    let navigationHeight: CGFloat = 70
    let generalView = GeneralComponentView()
    /* service */
    let calendarService = CalendarService()
    let incConsSecService = IncConSecCatgService()
    let incConsService = IncomeConsumeService()
    let budgetService = BudgetService()
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Header(size: geometry.size)
                ScrollView {
                    budgetTotalInput()
                    budgetDetailInput()
                }.padding(.horizontal, 20)
                    .scrollIndicators(.hidden)
            }
        }.navigationBarBackButtonHidden(true)
            .custumFullScreenCover(isPresented: $popUpFlg, transition: .opacity) {
//                PopUpView(accentColors: accentColors,
//                          popUpFlg: $popUpFlg,
//                          status: popUpStatus,
//                          selectDate: selectDate,
//                          inputTitle: popUpStatus == .addBalance ? "予算の設定" : "予算の変更",
//                          inputPlaceHolder: "未設定",
//                          inputText: budgetObj != nil ? String(budgetObj!.budgetAmtTotal) : ""
//                )
                if self.popUpStatus == .addBudget {
                    InputPopUpView(accentColors: accentColors,
                                   popUpFlg: $popUpFlg,
                                   inputText: $inputBudgetAmt,
                                   title: "予算の設定",
                                   placeHolder: "未設定") {
                        budgetService.registBudget(selectDate: selectDate, amount: inputBudgetAmt)
                    }
                } else if self.popUpStatus == .updateBudget {
                    InputPopUpView(accentColors: accentColors,
                                   popUpFlg: $popUpFlg,
                                   inputText: $inputBudgetAmt,
                                   title: "予算の変更",
                                   placeHolder: "未設定") {
                        budgetService.updateBudget(selectDate: selectDate, amount: inputBudgetAmt)
                    }
                } else if self.popUpStatus == .changeDate {
                    GeneralPopUpView(popUpFlg: $popUpFlg) {
                        let yyyyMM = calendarService.getStringDate(date: selectDate, format: "YYYY年M月")
                        Text(yyyyMM)
                            .foregroundStyle(Color.changeableText)
                            .font(.subheadline)
                    }
                }
            }.onChange(of: selectDate) {
                budgetObj = budgetService.getBudgetInfo(selectDate: selectDate)
            }.onChange(of: popUpFlg) {
                budgetObj = budgetService.getBudgetInfo(selectDate: selectDate)
            }
    }
    
    @ViewBuilder
    func Header(size: CGSize) -> some View {
        ZStack {
            LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .frame(height: navigationHeight)
            VStack {
                HStack {
                    Button(action: {
                        self.budgetDestFlg = false
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            self.popUpFlg = true
                            if budgetObj != nil {
                                self.popUpStatus = .updateBudget
                                inputBudgetAmt = String(budgetObj!.budgetAmtTotal)
                            } else {
                                self.popUpStatus = .addBudget
                                inputBudgetAmt = ""
                            }
                        }
                    }) {
                        Text("設定")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                    }
                }.padding(.bottom, 10)
                DateSelector()
            }.frame(maxHeight: navigationHeight ,alignment: .top)
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    func DateSelector() -> some View {
        let dateStr = calendarService.getStringDate(date: selectDate, format: "yyyy年MM月")
        HStack {
            Text(dateStr)
                .foregroundStyle(.white)
                .fontWeight(.bold)
            Spacer()
            Button(action: {
                withAnimation {
                    self.selectDate = calendarService.previewMonth(date: selectDate)
                    self.popUpFlg = true
                    self.popUpStatus = .changeDate
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
            }.padding(.trailing, 5)
            Button(action: {
                withAnimation {
                    self.selectDate = calendarService.nextMonth(date: selectDate)
                    self.popUpFlg = true
                    self.popUpStatus = .changeDate
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
            }.padding(.leading, 5)
        }
    }
    
    @ViewBuilder
    func budgetTotalInput() -> some View {
        let budgetRate: Double = budgetService.getBudgetRate(selectDate: selectDate)
        let consTotal = incConsService.getMonthIncOrConsAmtTotal(date: selectDate, houseHoldType: 1)
        ZStack {
            Circle()
                .stroke(lineWidth: 15)
                .fill(Color(uiColor: .systemGray6)
                    .shadow(.inner(color: Color(uiColor: .systemGray3), radius: 3))
                ).overlay {
                    Circle()
                        .trim(from: 0, to: budgetRate)
                        .stroke(lineWidth: 8)
                        .fill(.linearGradient(colors: accentColors,
                                              startPoint: .topLeading, endPoint: .bottomLeading))
                        .rotationEffect(.degrees(270))
                }
            VStack {
                if budgetObj != nil {
                    Text("予算残高")
                    Text("¥\(budgetObj!.budgetAmtTotal - consTotal)")
                        .font(.title)
                    Text("¥\(budgetObj!.budgetAmtTotal)")
                        .font(.caption)
                        .foregroundStyle(.gray)
                } else {
                    Text("予算がありません。")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
                
            }.foregroundStyle(Color.changeableText)
        }.padding(.vertical, 20)
            .padding(.horizontal, 80)
    }
    
    @ViewBuilder
    func budgetDetailInput() -> some View {
        let secResults = incConsSecService.getIncConsSecResults(houseHoldType: 1)
        let dicConsAmtBySec = incConsService.getConsTotalBySec(date: selectDate)
        VStack {
            ForEach(secResults.indices, id: \.self) { index in
                let secResult = secResults[index]
                let color = ColorAndImage.colors[secResult.incConsSecColorIndex]
                let imageNm = secResult.incConsSecImage
                let consTotalBySec = dicConsAmtBySec[secResult.incConsSecKey]!
                HStack {
                    generalView.RoundedIcon(radius: 10, color: color, image: imageNm, text: "")
                        .frame(width: 40, height: 40)
                    Text(secResult.incConsSecName)
                        .foregroundStyle(Color.changeableText)
                    Spacer()
                    Text("¥\(consTotalBySec)")
                        .foregroundStyle(Color.changeableText)
                }
            }
        }
    }
}

#Preview {
    @State var budgetDestFlg = true
    return BudgetView(accentColors: [.mint, .blue], budgetDestFlg: $budgetDestFlg)
}
