//
//  ReportView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2023/08/02.
//

import SwiftUI

struct SettingMenu: View {
    var accentColors: [Color]
    @Binding var popUpFlg: Bool
    @Binding var popUpStatus: PopUpStatus
    @Environment(\.colorScheme) var colorScheme
    @State var isPresented = false
    @State var pageStatus: PageStatusFromSetting = .howToUse
    let generalView = GeneralComponentView()
    let commonService = CommonService()
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    header()
                    ScrollView {
                        VStack(spacing: 40) {
                            HStack(spacing: 40) {
                                changeAccentColor()
                                howTo()
                            }
                            HStack(spacing: 40) {
                                changeIncConsSection()
                                budget()
                            }
                        }.padding()
                    }
                }
            }.padding(.bottom, 100)
                .navigationDestination(isPresented: $isPresented) {
                    switch pageStatus {
                    case .howToUse:
                        Text("")
                    case .secCatg:
                        IncConsSecListView(accentColors: accentColors,
                                           isSecPresented: $isPresented)
                    case .budget:
                        BudgetView(accentColors: accentColors,
                                   budgetDestFlg: $isPresented)
                    }
                }
        }
    }
    
    @ViewBuilder
    func header() -> some View {
        HStack(spacing: 0) {
            Text("メニュー")
                .font(.title.bold())
            Spacer()
        }.foregroundStyle(Color.changeableText)
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func howTo() -> some View {
        generalView.menuIconButton(isColorCard: false,
                                   accentColors: accentColors,
                                   iconNm: "使い方",
                                   imageNm: "questionmark.circle") {
            self.isPresented = true
            self.pageStatus = .howToUse
        }.compositingGroup()
            .shadow(color: colorScheme == .dark ? .clear : Color(uiColor: .systemGray4),radius: 8)
    }
    
    @ViewBuilder
    func changeAccentColor() -> some View {
        generalView.menuIconButton(isColorCard: true,
                                   accentColors: accentColors,
                                   iconNm: "テーマカラー",
                                   imageNm: "paintpalette") {
            withAnimation {
                self.popUpFlg = true
                self.popUpStatus = .selectAccentColor
            }
        }.compositingGroup()
            .shadow(color: colorScheme == .dark ? .clear : Color(uiColor: .systemGray),radius: 8)
    }
    
    @ViewBuilder
    func changeIncConsSection() -> some View {
        generalView.menuIconButton(isColorCard: false,
                                   accentColors: accentColors,
                                   iconNm: "項目・カテゴリー",
                                   imageNm: "rectangle.grid.2x2") {
                self.isPresented = true
                self.pageStatus = .secCatg
        }.compositingGroup()
            .shadow(color: colorScheme == .dark ? .clear : Color(uiColor: .systemGray4),radius: 8)
    }
    
    @ViewBuilder
    func budget() -> some View {
        generalView.menuIconButton(isColorCard: false,
                                   accentColors: accentColors,
                                   iconNm: "予算の設定",
                                   imageNm: "chineseyuanrenminbisign.square") {
            self.isPresented = true
            self.pageStatus = .budget
        }.compositingGroup()
            .shadow(color: colorScheme == .dark ? .clear : Color(uiColor: .systemGray4),radius: 8)
    }

}

enum PageStatusFromSetting {
    case howToUse
    case secCatg
    case budget
}

#Preview {
    @State var popUpFlg = false
    @State var popUpStatus: PopUpStatus = .selectAccentColor
    return SettingMenu(accentColors: [Color.purple, Color.indigo], popUpFlg: $popUpFlg, popUpStatus: $popUpStatus)
}
