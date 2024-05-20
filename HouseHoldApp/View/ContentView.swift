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
    /** ビュー関連 */
    var body: some View {
    @State var accentColors = GradientAccentcColors.gradients[accentColorsIndex]
        NavigationStack {
            ZStack(alignment: .bottom) {
                switch selectedContent {
                case 0:
                    WholeSummary(accentColors: accentColors)
                case 1:
                    BalanceSummaryView(accentColors: accentColors)
                case 2:
                    PaymentView(accentColors: accentColors)
                case 3:
                    SettingMenu(accentColors: accentColors)
                default:
                    WholeSummary(accentColors: accentColors)
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
            }.ignoresSafeArea(edges: .bottom)
        }
    }
}

#Preview {
    ContentView()
}
