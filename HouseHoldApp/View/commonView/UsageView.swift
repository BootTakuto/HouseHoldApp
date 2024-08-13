//
//  HowToUseView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/08/11.
//

import SwiftUI

struct UsageView: View {
    @Binding var isPresented: Bool
    @AppStorage("FIRST_OPEN_FLG") var firstOpenFlg = true
    @State var pageIndex = 0
    var body: some View {
        VStack {
            Header()
            TabView(selection: $pageIndex) {
                ExplainOverView().tag(0)
                ExplainHomeView().tag(1)
                ExplainBalanceView().tag(2)
                ExplainPaymentView().tag(3)
                ExplainSettingMenuView().tag(4)
            }.tabViewStyle(PageTabViewStyle())
        }.navigationBarBackButtonHidden(true)
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.changeableText)
            UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.changeableText).withAlphaComponent(0.2)
        }
    }
    
    @ViewBuilder
    func Header() -> some View {
        HStack {
            Button (action: {
                self.isPresented = false
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.changeableText)
            }
            Spacer()
        }.padding(10)
    }
    
    @ViewBuilder
    func ExplainOverView() -> some View {
        VStack {
            Text("概要説明")
        }
    }
    
    @ViewBuilder
    func ExplainHomeView() -> some View {
        VStack {
            Text("ホーム画面説明")
        }
    }
    
    @ViewBuilder
    func ExplainBalanceView() -> some View {
        VStack {
            Text("残高画面説明")
        }
    }
    
    @ViewBuilder
    func ExplainPaymentView() -> some View {
        VStack {
            Text("入出金説明")
        }
    }
    
    @ViewBuilder
    func ExplainSettingMenuView() -> some View {
        VStack {
            Text("設定メニュー画面説明")
        }
    }
}

#Preview {
    @State var isPresented = false
    return UsageView(isPresented: $isPresented)
}
