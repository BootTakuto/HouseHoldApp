//
//  IncConsSecCatgView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/06/08.
//

import SwiftUI

struct IncConsSecListView: View {
    var accentColors: [Color]
    @Binding var isSecPresented: Bool
    @State var isCatgPresented = false
    @State var popUpFlg = false
    @State var popUpStatus: PopUpStatus = .addIncConsSec
    @State var houseHoldType = 0
    // 登録情報
    @State var secKey = ""
    @State var secNm = ""
    @State var colorIndex = 0
    @State var imageNm = ColorAndImage.imageNames[0]
    
    @State var incConsSecResults = IncConSecCatgService().getIncConsSecResults(houseHoldType: 0)
    @State var incConsSecObject = IncConsSectionModel()
    let incConsSecCatgService = IncConSecCatgService()
    let generalView = GeneralComponentView()
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let global = geometry.frame(in: .global)
                let maxX = global.maxX
                VStack {
                    header(size: geometry.size)
                    TabView(selection: $houseHoldType) {
                        list()
                            .tag(0)
                        list()
                            .tag(1)
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
                generalView.glassCircleButton(imageColor: .changeableText, imageNm: "plus") {
                    withAnimation {
                        self.popUpFlg = true
                        self.popUpStatus = .addIncConsSec
                        self.secNm = ""
                        self.colorIndex = 0
                        self.imageNm = ColorAndImage.imageNames[0]
                    }
                }.frame(width: 60, height: 60)
                .shadow(radius: 10)
                .offset(x: maxX - 100, y: global.height - 80)
            }
        }.navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $isCatgPresented) {
                IncConsCatgListView(accentColors: accentColors,
                                    isCatgPresented: $isCatgPresented,
                                    incConsSecObj: self.incConsSecObject)
            }
            .onChange(of: houseHoldType) {
                self.incConsSecResults =
                incConsSecCatgService.getIncConsSecResults(houseHoldType: houseHoldType)
            }.onChange(of: popUpFlg) {
                if !popUpFlg {
                    self.incConsSecResults =
                    incConsSecCatgService.getIncConsSecResults(houseHoldType: houseHoldType)
                }
            }
            .custumFullScreenCover(isPresented: $popUpFlg, transition: .opacity) {
                if popUpStatus == .addIncConsSec {
                    InputIncConsSecPopUpView(accentColors: accentColors,
                                             popUpFlg: $popUpFlg,
                                             incConsSecNm: $secNm,
                                             incConsImageNm: $imageNm,
                                             incConsColorIndex: $colorIndex,
                                             title: "項目の登録",
                                             buttonText: "保存") {
                        incConsSecCatgService.registIncConsSec(houseHoldType: self.houseHoldType,
                                                               sectionNm: self.secNm,
                                                               colorIndex: self.colorIndex,
                                                               imageNm: self.imageNm)
                    }
                } else if popUpStatus == .editIncConsSec {
                    InputIncConsSecPopUpView(accentColors: accentColors,
                                             popUpFlg: $popUpFlg,
                                             incConsSecNm: $secNm,
                                             incConsImageNm: $imageNm,
                                             incConsColorIndex: $colorIndex,
                                             title: "項目の変更",
                                             buttonText: "変更") {
                        incConsSecCatgService.updateIncConsSec(incConsSecKey: self.secKey,
                                                               incConsSecNm: self.secNm,
                                                               incConsSecColorIndex: self.colorIndex,
                                                               incConsSecImageNm: self.imageNm)
                    }
                } else if popUpStatus == .deleteIncConsSec {
//                    PopUpView(accentColors: accentColors,
//                              popUpFlg: $popUpFlg,
//                              status: popUpStatus,
//                              delTitle: self.houseHoldType == 0 ? "収入項目の削除" : "支出項目の削除",
//                              delExplain: "項目を削除します。よろしいですか。\n※該当する情報は「不明」で表示されます。",
//                              incConsSecKey: self.incConsSecObject.incConsSecKey,
//                              houseHoldType: self.houseHoldType)
                    DeletePopUpView(accentColors: accentColors,
                                    popUpFlg: $popUpFlg,
                                    title: self.houseHoldType == 0 ? "収入項目の削除" : "支出項目の削除",
                                    explain: "項目を削除します。よろしいですか。\n※該当する情報は「未分類」として表示されます") {
                        incConsSecCatgService.deleteIncConsSec(incConsSecKey: self.secKey)
                    }
                }
            }
    }
    
    @ViewBuilder
    func tabBar() -> some View {
        VStack {
            GeometryReader {
                let local = $0.frame(in: .local)
                let offset = local.width / 6
                let offsets: [CGFloat] = [offset - 15, offset * 4 - 15]
                HStack(spacing: 0) {
                    Group {
                        Text("収入")
                            .onTapGesture {
                                self.houseHoldType = 0
                            }
                        Text("支出")
                            .onTapGesture {
                                self.houseHoldType = 1
                            }
                    }.frame(width: local.size.width / 2)
                }.font(.system(size: 14).bold())
                    .foregroundStyle(.white)
                RoundedRectangle(cornerRadius: 25)
                    .fill(.white)
                    .frame(width: local.width / 6 + 30, height: 5)
                    .animation(
                        .spring(), value: houseHoldType
                    )
                    .offset(x: offsets[houseHoldType], y: local.maxY)
            }
        }.frame(height: 20)
    }
    
    @ViewBuilder
    func header(size: CGSize) -> some View {
        ZStack(alignment: .top) {
            LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                .frame(height: 70)
            VStack {
                HStack {
                    Button(action: {
                        self.isSecPresented = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }.padding(.bottom, 10)
                tabBar()
            }.padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    func secCard(result: IncConsSectionModel, color: Color) -> some View {
        ZStack {
            Group {
                Color.changeable
                generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
            }.clipShape(RoundedRectangle(cornerRadius: 10))
            HStack {
                generalView.RoundedIcon(radius: 5,
                                        color: color,
                                        image: result.incConsSecImage,
                                        text: "")
                .frame(width: 50, height: 50)
                .fontWeight(.medium)
                .padding(10)
                VStack(alignment: .leading) {
                    Text(result.incConsSecName)
                        .foregroundStyle(Color.changeableText)
                        .fontWeight(.medium)
                    HStack {
                        let catgDispText = getCatgDisplayText(result: result)
                        Text(catgDispText)
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.gray)
                    }.lineLimit(1)
                        .padding(.trailing, 10)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Color.changeableText)
                    .padding(.trailing, 10)
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func getCatgDisplayText(result: IncConsSectionModel) -> String {
        var dispText = ""
        result.incConsCatgOfSecList.indices.forEach { index in
            let catgObj = result.incConsCatgOfSecList[index]
            dispText += catgObj.incConsCatgNm + " "
        }
        return dispText
    }
    
    @ViewBuilder
    func list() -> some View {
        let isEmpty = self.incConsSecResults.isEmpty
        if isEmpty {
            Text(self.houseHoldType == 0 ? "収入項目が存在しません。" : "支出項目が存在しません。")
                .foregroundStyle(Color.changeableText)
                .fontWeight(.medium)
        } else {
            ScrollView {
                VStack {
                    ForEach(self.incConsSecResults.indices, id: \.self) { secIndex in
                        let result = self.incConsSecResults[secIndex]
                        let color = ColorAndImage.colors[result.incConsSecColorIndex]
                        SwipeActioin(direction: .trailing) {
                            Button(action: {
                                self.isCatgPresented = true
                                self.incConsSecObject = result
                            }) {
                                secCard(result: result, color: color)
                            }
                        } actions: {
                            Action(buttonColor: .gray, iconNm: "pencil.line") {
                                withAnimation {
                                    self.popUpFlg = true
                                    self.popUpStatus = .editIncConsSec
                                    self.secKey = result.incConsSecKey
                                    self.secNm = result.incConsSecName
                                    self.colorIndex = result.incConsSecColorIndex
                                    self.imageNm = result.incConsSecImage
//                                    self.incConsSecObject = result
                                }
                            }
                            Action(buttonColor: .red, iconNm: "trash") {
                                withAnimation {
                                    self.popUpFlg = true
                                    self.popUpStatus = .deleteIncConsSec
                                    self.secKey = result.incConsSecKey
//                                    self.incConsSecObject = result
                                }
                            }
                        }.clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }.padding(.horizontal, 20)
                    .padding(.top, 5)
                    .padding(.bottom, 100)
            }.scrollIndicators(.hidden)
        }
    }
    
}

#Preview {
    @State var isPresented = false
    @State var popUpFlg = false
    @State var popUpStatus: PopUpStatus = .addIncConsSec
    return IncConsSecListView(accentColors: [.purple, .blue],
                              isSecPresented: $isPresented)
}
