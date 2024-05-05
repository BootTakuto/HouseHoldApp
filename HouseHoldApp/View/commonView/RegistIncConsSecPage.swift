//
//  RegistIncConsSecView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/04.
//

import SwiftUI

struct RegistIncConsSecPage: View {
    var accentColors: [Color]
    @Binding var registIncConsFlg: Bool
    @Binding var registIncConsSecFlg: Bool
    @Binding var selectedInc: Bool
    var editSecFlg: Bool
    var incConsSecKey: String
    @State var incConsSecNm = ""
    @State var colorIndex: Int = 0
    @State var imageIndex: Int = 0
    let screen = UIScreen.main.bounds
    // service
    let incConsService = IncConSecCatgService()
    // 汎用ビュー
    let generalView = GeneralComponentView()
    var body: some View {
        ZStack {
//            LinearGradient(colors: accentColors,
//                           startPoint: .top,
//                           endPoint: .bottom)
//            .ignoresSafeArea()
//            generalView.GradientBackGround(colors: accentColors)
//            generalView.BlurDotBackGround(colors: accentColors)
            VStack {
                HStack {
                    Button(action: {
                        self.registIncConsSecFlg = false
                        print(registIncConsSecFlg)
                    }) {
                        Image(systemName: "arrow.backward")
                            .foregroundColor(.white)
                            .font(.title2)
                    }
                    Spacer()
                    Text("収支項目の登録")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                    Button(action: {
                        
                    }) {
                        Image(systemName: "questionmark.circle")
                            .foregroundStyle(.white)
                    }
                    Spacer()
                    Button(action: {
                        self.registIncConsFlg = false
                    }) {
                        Image(systemName: "xmark.circle")
                            .foregroundStyle(.white)
                    }
                }.frame(width: screen.width - 50)
                    .padding(.top, 20)
                ZStack {
//                    RoundedRectangle(cornerRadius: 25)
//                        .fill(.white.opacity(0.2))
//                        .background(
//                            RoundedRectangle(cornerRadius: 25)
//                                .stroke(lineWidth: 1.5)
//                                .fill(
//                                    LinearGradient(colors: [
//                                        .white, .white.opacity(0.5), .clear, .clear, accentColors[2].opacity(0.5), accentColors[2]],
//                                                   startPoint: .topLeading,
//                                                   endPoint: .bottomTrailing))
//                        ).compositingGroup()
//                        .shadow(color: Color.black.opacity(0.8), radius: 5)
//                    generalView.GlassGradient(color: accentColors[0],
//                                              w: screen.width - 30,
//                                              h: screen.height - 150)
                    inputForm()
                }.frame(width: screen.width - 30, height: screen.height - 150)
            }
        }.navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    func incConsSelectPicker() -> some View {
        let labels = ["収入", "支出"]
        GeometryReader {geometry in
            let size = geometry.size
            let midX = geometry.frame(in: .local).midX
            ZStack {
                RoundedRectangle(cornerRadius: 50)
                    .fill(.white.opacity(0.3))
                GeometryReader { _ in
                    RoundedRectangle(cornerRadius: 50)
                        .fill(accentColors[0])
                        .offset(x: selectedInc ? 0 : midX)
                        .frame(width: size.width / 2)
                        .compositingGroup()
                        .shadow(color: .black.opacity(0.5), radius: 3)
                }
                HStack(spacing: 0) {
                    ForEach(labels, id: \.self) { label in
                        Text("\(label)")
                            .font(.caption.bold())
                            .frame(width: size.width / 2)
                            .foregroundStyle(.white)
                            .onTapGesture {
                                withAnimation(
                                    .interpolatingSpring(
                                        mass: 1.0,
                                        stiffness: 240.0,
                                        damping: 18.0,
                                        initialVelocity: 2.0
                                    )) {
                                        self.selectedInc = label == "収入" ? true : false
                                    }
                            }
                    }
                }
            }
        }.frame(width: screen.width / 2, height: 30)
    }
    
    // ボーダー
    @ViewBuilder
    func Border(width: CGFloat) -> some View {
        Rectangle()
            .fill(.gray)
            .frame(width: width, height: 1)
            .padding(.bottom, 5)
    }
    
    @ViewBuilder
    func inputForm() -> some View {
        let formWidth = screen.width - 80
        ScrollView {
            VStack {
                incConsSelectPicker()
                    .padding(.vertical, 20)
                Text("項目名")
                    .font(.caption.bold())
                    .foregroundStyle(Color.changeableText)
                    .frame(maxWidth: formWidth, alignment: .leading)
                Border(width: formWidth)
                TextField("項目名の入力", text: $incConsSecNm)
                    .padding()
                    .frame(width: formWidth, height: 50)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(.white.opacity(0.3))
                    )
                    .foregroundStyle(Color.changeableText)
                Text("カラー")
                    .font(.caption.bold())
                    .foregroundStyle(Color.changeableText)
                    .frame(maxWidth: formWidth, alignment: .leading)
                    .padding(.top, 10)
                Border(width: formWidth)
                GeometryReader { geometry in
                    let width = geometry.frame(in: .global).width
                    ScrollView {
                        VStack(spacing: 0) {
                            let columns = 5
                            let rows = ColorAndImage.colors.count / columns
                            ForEach(0 ..< rows, id:\.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(0 ..< columns, id:\.self) { colomun in
                                        let index = colomun + (row * columns)
                                        let color = ColorAndImage.colors[index]
                                        let rectWidth = width / CGFloat(columns) - 10
                                        Button(action: {
                                            self.colorIndex = index
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(color)
                                                    .frame(width: self.colorIndex == index ? rectWidth + 5 : rectWidth,
                                                           height: self.colorIndex == index ? rectWidth + 5 : rectWidth)
                                                    .foregroundStyle(.gray)
                                            }
                                            .padding(self.colorIndex == index ? 2.5 : 5)
                                                .compositingGroup()
                                                .shadow(color: Color.black.opacity(0.5), radius: 3)
                                        }
                                    }
                                }
                            }
                        }
                    }.scrollIndicators(.hidden)
                }.frame(width: formWidth, height: 150)
                Text("イメージ")
                    .font(.caption.bold())
                    .foregroundStyle(Color.changeableText)
                    .frame(maxWidth: formWidth, alignment: .leading)
                    .padding(.top, 10)
                Border(width: formWidth)
                GeometryReader { geometry in
                    let width = geometry.frame(in: .global).width
                    ScrollView {
                        VStack(spacing: 0) {
                            let columns = 5
                            let rows = ColorAndImage.imageNames.count / columns
                            ForEach(0 ..< rows, id:\.self) { row in
                                HStack(spacing: 0) {
                                    ForEach(0 ..< columns, id:\.self) { colomun in
                                        let index = colomun + (row * columns)
                                        let imageName = ColorAndImage.imageNames[index]
                                        let rectWidth = width / CGFloat(columns) - 10
                                        Button(action: {
                                            self.imageIndex = index
                                        }) {
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 15)
                                                    .fill(self.imageIndex == index ? ColorAndImage.colors[colorIndex] : .white)
                                                    .frame(width: self.imageIndex == index ? rectWidth + 5 : rectWidth,
                                                           height: self.imageIndex == index ? rectWidth + 5 : rectWidth)
                                                Image(systemName: imageName)
                                                    .foregroundStyle(self.imageIndex == index ? .white : .gray)
                                            }.padding(self.imageIndex == index ? 2.5 : 5)
                                                .compositingGroup()
                                                .shadow(color: Color.black.opacity(0.5), radius: 3)
                                        }
                                    }
                                }
                            }
                        }
                    }.scrollIndicators(.hidden)
                }.frame(width: formWidth, height: 150)
                Button(action: {
                    if self.editSecFlg {
                        print("編集")
                    } else {
                        incConsService.registIncConsSec(incFlg: selectedInc,
                                                        sectionNm: incConsSecNm,
                                                        colorIndex: colorIndex,
                                                        imageNm: ColorAndImage.imageNames[imageIndex])
                        self.incConsSecNm = ""
                    }
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(self.incConsSecNm == "" ? .white.opacity(0.3) : accentColors[0])
                        Text(self.editSecFlg ? "変更を確定" :"新規登録")
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                }.frame(width: formWidth, height: 60)
                    .padding(.vertical, 20)
                    .compositingGroup()
                    .shadow(color: Color.black.opacity(0.2), radius: 5)
                    .disabled(self.incConsSecNm == "")
            }.frame(width: formWidth + 15)
        }.scrollIndicators(.hidden)
    }
}

#Preview {
    @State var registIncConsFlg = true
    @State var registIncConsSecFlg = false
    @State var selectedInc = true
    return RegistIncConsSecPage(accentColors: [.purple, .indigo, .blue],
                                registIncConsFlg: $registIncConsFlg,
                                registIncConsSecFlg: $registIncConsSecFlg,
                                selectedInc: $selectedInc,
                                editSecFlg: false,
                                incConsSecKey: "")
}
