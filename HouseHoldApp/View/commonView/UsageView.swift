//
//  HowToUseView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/08/11.
//

import SwiftUI

struct UsageView: View {
    @Binding var isPresented: Bool
    @State var isOpenModal = false
    @AppStorage("FIRST_OPEN_FLG") var firstOpenFlg = true
    @State var pageIndex = 0
    let viewModelService = ViewModelService()
    let generalView = GeneralComponentView()
    var body: some View {
        VStack {
            Header()
            ScrollView {
                ButtonList()
            }
        }.navigationBarBackButtonHidden(true)
            .custumFullScreenCover(isPresented: $isOpenModal, transition: .opacity) {
                Button(action: {
                    self.isOpenModal = false
                }) {
                    Text("aaaa")
                }
            }
       
            
//                .onAppear {
//                    UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(Color.changeableText)
//                    UIPageControl.appearance().pageIndicatorTintColor = UIColor(Color.changeableText).withAlphaComponent(0.2)
//                }
    }
    
    @ViewBuilder
    func Header() -> some View {
//        let titles = ["残高", "家計入力", "家計把握", "予算設定", "収支項目・カテゴリー"]
        HStack {
            Button (action: {
                self.isPresented = false
            }) {
                Image(systemName: "arrow.left")
                    .foregroundColor(.changeableText)
            }
            Spacer()
        }.overlay {
            HStack(spacing: 5) {
                Text("使い方")
                Image(systemName: "questionmark.circle")
            }.foregroundStyle(Color.changeableText)
                .fontWeight(.medium)
        }.padding(.top, 10)
        .padding(.bottom, 5)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    func ButtonList() -> some View {
        let labels = ["このアプリの基本機能", "", "", "", ""]
        VStack(spacing: 20) {
            ForEach(0 ..< 5, id: \.self) { index in
                Button(action: {
                    self.isOpenModal = true
                }) {
                    generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                        .frame(height: 50)
                        .shadow(radius: 5)
                        .overlay {
                            HStack {
                                Text(labels[index])
                                    .foregroundStyle(Color.changeableText)
                                Spacer()
                            }.padding(.horizontal)
                        }.padding(.horizontal, 20)
                }
            }
        }.padding(.vertical, 20)
    }
    
    @ViewBuilder
    func ExplainSecondOverView() -> some View {
        GeometryReader {
            let size = $0.size
            ScrollView {
                VStack {
                    HStack {
                        Text("家計の登録")
                            .underline(color: Color.changeableText)
                            .foregroundStyle(Color.changeableText)
                        Spacer()
                    }.padding(.horizontal, 10)
                        .padding(.bottom, 5)
                    ZStack(alignment: .bottom) {
                        generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                        HStack(spacing: 20) {
                            Image("inputWithoutBalComp")
                                .resizable()
                                .scaledToFit()
                                .clipShape (
                                    .rect(
                                        topLeadingRadius: 30,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 30
                                    )
                                ).shadow(radius: 10, x: 10, y: 10)
                                .padding(.top, 10)
                            Text("収入・支出の金額が何で、いつ発生したものか登録できます。")
                                .font(.footnote)
                                .foregroundStyle(Color.changeableText)
                                .frame(width: 150)
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 350)
                        .padding(.bottom, 20)
                    HStack {
                        Text("収支金額を残高に連携することも")
                            .underline(color: Color.changeableText)
                            .foregroundStyle(Color.changeableText)
                        Spacer()
                    }.padding(.horizontal, 10)
                        .padding(.bottom, 5)
                    ZStack(alignment: .bottom) {
                        generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                            VStack(spacing: 0) {
                                Text("残高を連携、選択し登録することで、残高金額に収支増減額を反映できます。")
                                    .font(.caption)
                                    .foregroundStyle(Color.changeableText)
                                    .padding(.vertical, 20)
                                    .frame(width: 300)
                                HStack(spacing: 20) {
                                    Image("inputWithBalComp")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape (
                                            .rect(
                                                topLeadingRadius: 25,
                                                bottomLeadingRadius: 0,
                                                bottomTrailingRadius: 0,
                                                topTrailingRadius: 25
                                            )
                                        ).shadow(radius: 10, x: 10, y: 10)
                                    Image("consRefBalComp")
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape (
                                            .rect(
                                                topLeadingRadius: 25,
                                                bottomLeadingRadius: 0,
                                                bottomTrailingRadius: 0,
                                                topTrailingRadius: 25
                                            )
                                        ).shadow(radius: 10, x: 10, y: 10)
                                }
                            }
                }.clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 320)
                Spacer()
                }.padding(10)
            }.frame(height: size.height - 50)
        }
    }
    
    @ViewBuilder
    func ExplainThirdOverView() -> some View {
        GeometryReader {
            let size = $0.size
            ScrollView {
                VStack {
                    HStack {
                        Text("入出金を一覧で確認")
                            .underline(color: Color.changeableText)
                            .foregroundStyle(Color.changeableText)
                        Spacer()
                    }.padding(.horizontal, 10)
                        .padding(.bottom, 5)
                    ZStack(alignment: .bottom) {
                        generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                        HStack(spacing: 20) {
                            Image("paymentListComp")
                                .resizable()
                                .scaledToFit()
                                .clipShape (
                                    .rect(
                                        topLeadingRadius: 30,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 30
                                    )
                                ).shadow(radius: 10, x: 10, y: 10)
                                .padding(.top, 10)
                            Text("個々で登録した収入・支出の金額は、月間ごと日付別で一覧にして表示します。")
                                .font(.footnote)
                                .foregroundStyle(Color.changeableText)
                                .frame(width: 150)
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 350)
                        .padding(.bottom, 20)
                    HStack {
                        Text("入出金をカレンダーで確認")
                            .underline(color: Color.changeableText)
                            .foregroundStyle(Color.changeableText)
                        Spacer()
                    }.padding(.horizontal, 10)
                        .padding(.bottom, 5)
                    ZStack(alignment: .bottom) {
                        generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                        HStack(spacing: 20) {
                            Image("paymentCalendarComp")
                                .resizable()
                                .scaledToFit()
                                .clipShape (
                                    .rect(
                                        topLeadingRadius: 30,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 30
                                    )
                                ).shadow(radius: 10, x: 10, y: 10)
                                .padding(.top, 10)
                            Text("カレンダーでは日付ごと、その日に登録された収入・支出の金額の合計をそれぞれ表示します。")
                                .font(.footnote)
                                .foregroundStyle(Color.changeableText)
                                .frame(width: 150)
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 350)
                        .padding(.bottom, 20)
                Spacer()
                }.padding(10)
            }.frame(height: size.height - 50)
        }
    }
    
    @ViewBuilder
    func ExplainAnotherOverView() -> some View {
        GeometryReader {
            let size = $0.size
            ScrollView {
                VStack {
                    HStack {
                        Text("予算の設定")
                            .underline(color: Color.changeableText)
                            .foregroundStyle(Color.changeableText)
                        Spacer()
                    }.padding(.horizontal, 10)
                        .padding(.bottom, 5)
                    ZStack(alignment: .bottom) {
                        generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                        HStack(spacing: 20) {
                            Image("paymentListComp")
                                .resizable()
                                .scaledToFit()
                                .clipShape (
                                    .rect(
                                        topLeadingRadius: 30,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 30
                                    )
                                ).shadow(radius: 10, x: 10, y: 10)
                                .padding(.top, 10)
                            Text("個々で登録した収入・支出の金額は、月間ごと日付別で一覧にして表示します。")
                                .font(.footnote)
                                .foregroundStyle(Color.changeableText)
                                .frame(width: 150)
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 350)
                        .padding(.bottom, 20)
                    HStack {
                        Text("入出金をカレンダーで確認")
                            .underline(color: Color.changeableText)
                            .foregroundStyle(Color.changeableText)
                        Spacer()
                    }.padding(.horizontal, 10)
                        .padding(.bottom, 5)
                    ZStack(alignment: .bottom) {
                        generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                        HStack(spacing: 20) {
                            Image("paymentCalendarComp")
                                .resizable()
                                .scaledToFit()
                                .clipShape (
                                    .rect(
                                        topLeadingRadius: 30,
                                        bottomLeadingRadius: 0,
                                        bottomTrailingRadius: 0,
                                        topTrailingRadius: 30
                                    )
                                ).shadow(radius: 10, x: 10, y: 10)
                                .padding(.top, 10)
                            Text("カレンダーでは日付ごと、その日に登録された収入・支出の金額の合計をそれぞれ表示します。")
                                .font(.footnote)
                                .foregroundStyle(Color.changeableText)
                                .frame(width: 150)
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(height: 350)
                        .padding(.bottom, 20)
                Spacer()
                }.padding(10)
            }.frame(height: size.height - 50)
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
