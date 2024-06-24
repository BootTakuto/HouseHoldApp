//
//  IncConsCatgView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/06/17.
//

import SwiftUI
import RealmSwift

struct IncConsCatgListView: View {
    var accentColors: [Color]
    @Binding var isCatgPresented: Bool
    @State var incConsCatgResults = IncConSecCatgService().getIncConsCatgResults(secKey: "")
    @State var popUpFlg = false
    @State var popUpStatus: PopUpStatus = .addincConsCatg
    @State var incConsCatgObj = IncConsCategoryModel()
    var incConsSecObj: IncConsSectionModel
    // service
    let incConsSecCatgService = IncConSecCatgService()
    // 汎用ビュー
    let generalView = GeneralComponentView()
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geometry in
                    let global = geometry.frame(in: .global)
                    let maxX = global.maxX
                    VStack {
                        Header()
                        List()
                    }
                    generalView.glassCircleButton(imageColor: .changeableText, imageNm: "plus") {
                        withAnimation {
                            self.popUpFlg = true
                            self.popUpStatus = .addincConsCatg
                        }
                    }.frame(width: 60, height: 60)
                        .shadow(radius: 10)
                        .offset(x: maxX - 100, y: global.height - 80)
                }
            }
        }.navigationBarBackButtonHidden(true)
            .onAppear {
                let secKey = incConsSecObj.incConsSecKey
                self.incConsCatgResults = incConsSecCatgService.getIncConsCatgResults(secKey: secKey)
            }.custumFullScreenCover(isPresented: $popUpFlg, transition: .opacity) {
                if popUpStatus == .addincConsCatg {
                    PopUpView(accentColors: accentColors,
                              popUpFlg: $popUpFlg,
                              status: popUpStatus,
                              incConsSecKey: self.incConsSecObj.incConsSecKey,
                              inputTitle: "カテゴリーの登録",
                              inputPlaceHolder: "カテゴリー名")
                } else if popUpStatus == .editIncConsCatg {
                    PopUpView(accentColors: accentColors,
                              popUpFlg: $popUpFlg,
                              status: popUpStatus,
                              incConsCatgKey: self.incConsCatgObj.incConsCatgKey,
                              inputTitle: "カテゴリーの登録",
                              inputPlaceHolder: "カテゴリー名",
                              inputText: self.incConsCatgObj.incConsCatgNm)
                }
                else if popUpStatus == .deleteIncConsCatg {
                    PopUpView(accentColors: accentColors,
                              popUpFlg: $popUpFlg,
                              status: popUpStatus,
                              delTitle: "カテゴリーの削除",
                              delExplain: "カテゴリーを削除します。よろしいですか。\n※該当する情報は項目名で表示されます。",
                              incConsCatgKey: self.incConsCatgObj.incConsCatgKey)
                }
            }
    }
    
    @ViewBuilder
    func Header() -> some View {
        HStack {
            Button(action: {
                self.isCatgPresented = false
            }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.changeableText)
                    .fontWeight(.bold)
            }
            Spacer()
        }.padding(.bottom, 10)
            .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func List() -> some View {
        let color = ColorAndImage.colors[self.incConsSecObj.incConsSecColorIndex]
        let rectHeight: CGFloat = 70
        ScrollView {
            VStack(alignment: .trailing, spacing: 0) {
                ForEach(self.incConsCatgResults.indices, id: \.self) { index in
                    let result = self.incConsCatgResults[index]
                    SwipeActioin {
                        ZStack {
                            Color.changeable
                            UIGlassCard(effect: .systemThinMaterial)
                            HStack(spacing: 0) {
                                generalView.RoundedIcon(radius: 5,
                                                        color: color,
                                                        image: self.incConsSecObj.incConsSecImage,
                                                        text: self.incConsSecObj.incConsSecName)
                                .frame(width: 50, height: 50)
                                .fontWeight(.medium)
                                .padding(.vertical, 10)
                                Spacer()
                                Text(result.incConsCatgNm)
                                    .foregroundStyle(Color.changeableText)
                                    .fontWeight(.medium)
                            }.padding(.horizontal, 20)
                        }
                    } actions: {
                        Action(buttonColor: .gray, iconNm: "pencil.line") {
                            withAnimation {
                                self.incConsCatgObj = result
                                self.popUpFlg = true
                                self.popUpStatus = .editIncConsCatg
                            }
                        }
                        Action(buttonColor: .red, iconNm: "trash") {
                            withAnimation {
                                self.incConsCatgObj = result
                                self.popUpFlg = true
                                self.popUpStatus = .deleteIncConsCatg
                            }
                        }
                    }
                    if self.incConsCatgResults.count - 1 != index {
                        generalView.Border()
                            .foregroundStyle(Color(uiColor: .systemGray3))
                            .padding(.horizontal, 10)
                    }
                }
            }.clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(height: rectHeight * CGFloat(self.incConsCatgResults.count))
            .padding(.bottom, 100)
        }.padding(.horizontal, 20)
            .scrollIndicators(.hidden)
    }
}

//#Preview {
//    @State var isCatgPresented = false
//    
//    return IncConsCatgListView(isCatgPresented: $isCatgPresented,
//                               incConsSecObj: IncConsSectionModel())
//}

#Preview {
    @State var popUpFlg = false
    @State var popUpStatus: PopUpStatus = .selectAccentColor
    var accentColors = [Color.purple, Color.indigo]
    return SettingMenu(accentColors: accentColors, popUpFlg: $popUpFlg, popUpStatus: $popUpStatus)
}
