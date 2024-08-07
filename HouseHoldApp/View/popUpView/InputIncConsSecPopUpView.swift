//
//  InputIncConsSecPopUpView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/07/31.
//

import SwiftUI

struct InputIncConsSecPopUpView: View {
    var accentColors: [Color]
    @Binding var popUpFlg: Bool
    @Binding var incConsSecNm: String
    @Binding var incConsImageNm: String
    @Binding var incConsColorIndex: Int
    @FocusState var addIncConsNmFocused
    var title: String
    var buttonText: String
    // 汎用ビュー
    let generalView = GeneralComponentView()
    // 実行関数
    var action: () -> Void
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
            InputIncConSecAlert()
        }.ignoresSafeArea()
    }
    
    @ViewBuilder
    func InputIncConSecAlert() -> some View {
        let rectHeight: CGFloat = 500
//        let isEdit = self.status == .editIncConsSec
        ZStack {
            UIGlassCard(effect: .systemMaterial)
            VStack(spacing: 0) {
                VStack {
                    Text(title)
                        .fontWeight(.bold)
                    HStack {
                        Text("項目名(必須)")
                            .font(.footnote)
                        TextField("収入、食費・交通費など", text: $incConsSecNm)
                            .focused($addIncConsNmFocused)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 5)
                            .background(Color(uiColor: .systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .font(.footnote)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    Text("イメージ")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0 ..< 11, id: \.self) { row in
                                VStack {
                                    ForEach(0 ..< 3, id: \.self) { col in
                                        let index = col + (row * 3)
                                        if ColorAndImage.imageNames.count > index {
                                            let incConsImageNm = ColorAndImage.imageNames[index]
                                            Button(action: {
                                                self.incConsImageNm = incConsImageNm
                                            }) {
                                                ZStack {
                                                    if self.incConsImageNm == incConsImageNm {
                                                        RoundedRectangle(cornerRadius: 10)
                                                            .fill(ColorAndImage.colors[self.incConsColorIndex])
                                                    } else {
                                                        generalView.GlassBlur(effect: .systemThinMaterial, radius: 10)
                                                    }
                                                    Image(systemName: incConsImageNm)
                                                        .fontWeight(.medium)
                                                        .foregroundStyle(self.incConsImageNm == incConsImageNm ? .white : Color.changeableText)
                                                }
                                            }.frame(width: 40, height: 40)
                                        } else {
                                            Color.clear
                                                .frame(width: 40, height: 40)
                                        }
                                    }
                                }
                            }
                        }
                    }.frame(height: rectHeight / 4 + 20)
                    Text("カラー")
                        .font(.footnote)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 5)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0 ..< 10, id: \.self) { row in
                                VStack {
                                    ForEach(0 ..< 3, id: \.self) { col in
                                        let index = col + (row * 3)
                                        if ColorAndImage.colors.count > index {
                                            Button(action: {
                                                self.incConsColorIndex = index
                                            }) {
                                                let color = ColorAndImage.colors[index]
                                                RoundedRectangle(cornerRadius: 10)
                                                    .fill(color)
                                                    .frame(width: 40, height: 40)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 6.5)
                                                            .stroke(lineWidth: 3)
                                                            .fill(self.incConsColorIndex == index ? .white : .clear)
                                                            .frame(width: 30, height: 30)
                                                    )
                                            }
                                        } else {
                                            Color.clear
                                                .frame(width: 40, height: 40)
                                        }
                                    }
                                }
                            }
                        }
                    }.frame(height: rectHeight / 4 + 20)
                }.padding(.top, 20)
                    .padding(.horizontal, 20)
                Spacer()
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation {
                            self.popUpFlg = false
                        }
                    }) {
                        ZStack {
                            accentColors.last ?? .black
                            Text("キャンセル")
                        }
                    }
                    generalView.Bar()
                        .foregroundStyle(.changeable)
                    Button(action: {
//                        if isEdit {
//                            incConsSecCatgService.updateIncConsSec(incConsSecKey: self.incConsSecKey,
//                                                                   incConsSecNm: self.incConsSecNm,
//                                                                   incConsSecColorIndex: self.incConsColorIndex,
//                                                                   incConsSecImageNm: self.incConsImageNm)
//                        } else {
//                            incConsSecCatgService.registIncConsSec(houseHoldType: self.houseHoldType,
//                                                                   sectionNm: self.incConsSecNm,
//                                                                   colorIndex: self.incConsColorIndex,
//                                                                   imageNm: self.incConsImageNm)
//                        }
                        withAnimation {
                            action()
                            self.popUpFlg = false
                        }
                    }) {
                        ZStack {
                            accentColors.last ?? .black
                            Text(buttonText)
                        }
                    }
                }.frame(height: 40)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
            }.foregroundStyle(Color.changeableText)
        }.frame(height: rectHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 20)
    }
}

#Preview {
    @State var popUpFlg = false
    @State var incConsSecNm = ""
    @State var imageNm = ""
    @State var colorIndex = 0
    return InputIncConsSecPopUpView(accentColors: [.blue, .mint],
                                    popUpFlg: $popUpFlg,
                                    incConsSecNm: $incConsSecNm,
                                    incConsImageNm: $imageNm,
                                    incConsColorIndex: $colorIndex,
                                    title: "項目の登録",
                                    buttonText: "保存") {
        
    }
}
