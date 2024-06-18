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
    @State var popUpFlg = false
    @State var popUpStatus: PopUpStatus = .addBalance
    @State var balModel = BalanceModel()
    /** ビュー関連 */
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
                    PaymentView(accentColors: accentColors)
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
            }.custumFullScreenCover(isPresented: $popUpFlg, transition: .opacity) {
                if self.popUpStatus == .editBalance {
                    PopUpView(accentColors: accentColors,
                              popUpFlg: $popUpFlg,
                              status: popUpStatus,
                              balNm: self.balModel.balanceNm,
                              colorIndex: self.balModel.colorIndex,
                              balKey: self.balModel.balanceKey)
                } else if self.popUpStatus == .deleteBalance {
                    PopUpView(accentColors: accentColors,
                              popUpFlg: $popUpFlg,
                              status: popUpStatus,
                              balKey: self.balModel.balanceKey)
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
                } else {
                    PopUpView(accentColors: accentColors,
                              popUpFlg: $popUpFlg,
                              status: popUpStatus)
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    ContentView()
}
