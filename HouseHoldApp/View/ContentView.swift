//
//  ContentView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2023/08/01.
//

import SwiftUI
import RealmSwift

struct ContentView: View { 
    @AppStorage("FIRST_OPEN_FLG") var firstOpenFlg = true
    @AppStorage("ACCENT_COLORS_INDEX") var accentColorsIndex = 0
    @State var selectedContent = 0
    // popUp表示用変数
    @State var popUpFlg = false
    @State var popUpStatus: PopUpStatus = .addBalance
    // 残高view用変数
    @State var balNm = ""
    @State var colorIndex = 0
    @State var balModel = BalanceModel()
    // 入出金view用変数
    @State var selectDate = Date()  // paymentView 意外での使用はない
    @State var incConsKey = ""      // 削除用収入・支出主キー
    // service
    let balanceService = BalanceService()
    let calendarService = CalendarService()
    let incConsService = IncomeConsumeService()
    var body: some View {
    @State var accentColors = GradientAccentcColors.gradients[accentColorsIndex]
        NavigationStack {
            ZStack(alignment: .bottom) {
                switch selectedContent {
                case 0:
                    HomeView(accentColors: accentColors,
                                 popUpFlg: $popUpFlg,
                                 popUpStatus: $popUpStatus)
                case 1:
                    BalanceSummaryView(accentColors: accentColors,
                                       popUpFlg: $popUpFlg,
                                       popUpStatus: $popUpStatus,
                                       balModel: $balModel)
                case 2:
                    PaymentView(accentColors: accentColors,
                                popUpFlg: $popUpFlg,
                                popUpStatus: $popUpStatus,
                                selectDate: $selectDate,
                                incConsKey: $incConsKey)
                case 3:
                    SettingMenu(accentColors: accentColors,
                                popUpFlg: $popUpFlg,
                                popUpStatus: $popUpStatus)
                default:
                    HomeView(accentColors: accentColors,
                                 popUpFlg: $popUpFlg,
                                 popUpStatus: $popUpStatus)
                }
                ContentTabBar(accentColors: accentColors,
                              selectedContent: $selectedContent)
            }.onAppear {
                print(Realm.Configuration.defaultConfiguration.fileURL!)
                if firstOpenFlg {
                    @ObservedResults(IncConsSectionModel.self) var incConsSecResults
                    if incConsSecResults.isEmpty {
                        IncConSecCatgService().registOnlyFirstIncConsSecCatg()
                    }
                    self.firstOpenFlg = false
                }
            }.onChange(of: popUpFlg) {
                if popUpStatus == .editBalance {
                    self.balNm = balModel.balanceNm
                    self.colorIndex = balModel.colorIndex
                } else {
                    self.balNm = ""
                    self.colorIndex = 0
                }
            }.custumFullScreenCover(isPresented: $popUpFlg, transition: .opacity) {
                if self.popUpStatus == .addBalance {
//                    PopUpView(accentColors: accentColors,
//                              popUpFlg: $popUpFlg,
//                              status: popUpStatus,
//                              balNm: self.balModel.balanceNm,
//                              colorIndex: self.balModel.colorIndex,
//                              balKey: self.balModel.balanceKey)
                    InputBalancePopUpView(accentColors: accentColors,
                                          popUpFlg: $popUpFlg,
                                          balNm: $balNm,
                                          colorIndex: $colorIndex) {
                        balanceService.registBalance(balanceNm: balNm, colorIndex: colorIndex)
                    }
                } else if self.popUpStatus == .editBalance {
                    InputBalancePopUpView(accentColors: accentColors,
                                          popUpFlg: $popUpFlg,
                                          balNm: $balNm,
                                          colorIndex: $colorIndex) {
                        balanceService.updateBalance(balKey: balModel.balanceKey,
                                                     balNm: balNm,
                                                     colorIndex: colorIndex)
                    }
                } else if self.popUpStatus == .deleteBalance {
                    DeletePopUpView(accentColors: accentColors,
                                    popUpFlg: $popUpFlg,
                                    title: "残高の削除",
                                    explain: "「\(balModel.balanceNm)」を削除してよろしいですか。") {
                        balanceService.deleteBalance(balanceKey: balModel.balanceKey)
                    }
                } else if self.popUpStatus == .success {
//                    PopUpView(accentColors: accentColors,
//                              popUpFlg: $popUpFlg,
//                              status: popUpStatus,
//                              text: "登録成功",
//                              imageNm:"checkmark.circle")
                    GeneralPopUpView(popUpFlg: $popUpFlg) {
                        VStack(spacing: 5) {
                            Image(systemName: "checkmark.circle")
                                .font(.largeTitle)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.green)
                            Text("登録成功")
                                .foregroundStyle(Color.changeableText)
                        }
                    }
                } else if self.popUpStatus == .failed {
//                    PopUpView(accentColors: accentColors,
//                              popUpFlg: $popUpFlg,
//                              status: popUpStatus,
//                              text: "登録失敗",
//                              imageNm:"xmark.circle")
                    GeneralPopUpView(popUpFlg: $popUpFlg) {
                        VStack(spacing: 5) {
                            Image(systemName: "xmark.circle")
                                .font(.largeTitle)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.green)
                            Text("登録失敗")
                                .foregroundStyle(Color.changeableText)
                        }
                    }
                } else if self.popUpStatus == .changeDate {
                    GeneralPopUpView(popUpFlg: $popUpFlg) {
                        let yyyyMM = calendarService.getStringDate(date: selectDate, format: "YYYY年M月")
                        Text(yyyyMM)
                            .foregroundStyle(Color.changeableText)
                            .font(.subheadline)
                    }
                } else if self.popUpStatus == .deleteIncCons {
                    DeletePopUpView(accentColors: accentColors,
                                    popUpFlg: $popUpFlg,
                                    title: "収支情報の削除",
                                    explain: "この収支情報は完全に失われます。\nよろしいですか。") {
                        incConsService.deleteIncConsData(incConsKey: self.incConsKey)
                    }
                } else if self.popUpStatus == .selectAccentColor {
                    SelectAccentColorPopUpView(accentColors: accentColors,
                                               popUpFlg: $popUpFlg)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    ContentView()
}
