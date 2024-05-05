//
//  Test.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/01/13.
//

import SwiftUI

struct Test: View {
    @State var selectedContent = 0
    @State var text = ""
    @State var selected = 2
    
    var body: some View {
        //        VStack {
        //            Picker("", selection: $selected) {
        //                let viewNms = ["GGT", "CVT", "GT"]
        //                ForEach(0 ..< viewNms.count, id: \.self) { index in
        //                    Text(viewNms[index]).tag(index)
        //                }
        //            }.pickerStyle(.segmented)
        //            TabView(selection: $selected) {
        //                GlassGradiantTest().tag(0)
        //                ColorsVariationTest().tag(1)
        //                GradientsTest().tag(2)
        //            }
        //        }
        GeometryReader { geometry in
            ZStack {
//                DotBackGround()
//                let colors1: [Color] = [.pink, .purple, .orange]
//                let colors2: [Color] = [.blue, .purple, .mint]
//                let colors3: [Color] = [.red, .orange, .yellow]
//                let colors4: [Color] = [.green, .blue, .mint]
                DotBackGround()
//                GlassCard(color: colors1[0])
//                 ▼内部blurのcard
                UIGlassCard(effect: .systemUltraThinMaterial)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 20)
                    ).frame(width: geometry.size.width - 50)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(colors: [.white.opacity(0.5),
                                                            .white.opacity(0.2),
                                                            .clear,
                                                            .clear,
                                                            .purple.opacity(0.5),
                                                            .purple],
                                                   startPoint: .topLeading,
                                                   endPoint: .bottomTrailing),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: .gray, radius: 5)
            }
        }
    }
    @ViewBuilder
    func GlassCard(color: Color) -> some View {
        Color.gray.opacity(0.3)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(lineWidth: 2)
                    .fill(LinearGradient(colors: [.white,
                                                  .gray.opacity(0.5),
                                                  .black.opacity(0.3),
                                                  .black.opacity(0.3),
                                                  .gray.opacity(0.5),
                                                  color.opacity(0.5)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .padding()
            .shadow(color: .black, radius: 10)
    }
    
    @ViewBuilder
    func DotBackGround() -> some View {
        GeometryReader { geometry in
            let global = geometry.frame(in: .global)
            let midY = global.midY
            let midX = global.midX
            let width = global.width
//            let height = global.height
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.purple, .pink],
                                             startPoint: .topTrailing, endPoint: .bottomLeading)
                    ).shadow(color: Color(uiColor: .darkGray), radius: 5)
                    .offset(x: midX / 2 - 100, y: -midY / 2)
                    .frame(width: width / 2 + 80)
                Circle()
                    .fill(
                        LinearGradient(colors: [.pink, .purple],
                                             startPoint: .topTrailing, endPoint: .bottomLeading)
                    ).shadow(color: .gray, radius: 5)
                    .offset(x: midX - 80, y: midY / 2 - 100)
                    .frame(width: width / 2 - 140)
                Circle()
                    .fill(
                        LinearGradient(colors: [.pink, .purple],
                                             startPoint: .topTrailing, endPoint: .bottomLeading)
                    ).shadow(color: .gray, radius: 5)
                    .offset(x: midX + 30, y: midY / 2)
                    .frame(width: width / 2 - 80)
                Circle()
                    .fill(
                        LinearGradient(colors: [.purple, .orange],
                                             startPoint: .topTrailing, endPoint: .bottomLeading)
                    ).shadow(color: Color(uiColor: .darkGray), radius: 5)
                    .offset(x: -midX / 2, y: midY / 2 + 100)
                    .frame(width: width / 2 + 50)
                Circle()
                    .fill(
                        LinearGradient(colors: [.pink, .purple],
                                             startPoint: .topTrailing, endPoint: .bottomLeading)
                    ).shadow(color: Color(uiColor: .darkGray), radius: 5)
                    .offset(x: midX / 2 + 100, y: midY + 100)
                    .frame(width: width / 2 + 80)
            }
        }
    }
    
    @ViewBuilder
    func BlurDotBackGround(colors: [Color]) -> some View {
        GeometryReader { geometry in
            let global = geometry.frame(in: .global)
            let midY = global.midY
            let midX = global.midX
            let width = global.width
//            let height = global.height
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [colors[1], colors[0]],
                                             startPoint: .topTrailing, endPoint: .bottomLeading)
                    ).blur(radius: 15)
                    .offset(x: midX / 2 - 100, y: -midY / 2)
                    .frame(width: width / 2 + 80)
                Circle()
                    .fill(
                        LinearGradient(colors: [colors[0], colors[1]],
                                             startPoint: .topTrailing, endPoint: .bottomLeading)
                    ).blur(radius: 25)
                    .offset(x: midX - 80, y: midY / 2 - 100)
                    .frame(width: width / 2 - 140)
                Circle()
                    .fill(
                        LinearGradient(colors: [colors[1], colors[1]],
                                             startPoint: .topTrailing, endPoint: .bottomLeading)
                    ).blur(radius: 25)
                    .offset(x: midX + 30, y: midY / 2)
                    .frame(width: width / 2 - 80)
                Circle()
                    .fill(
                        LinearGradient(colors: [colors[1], colors[2]],
                                             startPoint: .topTrailing, endPoint: .bottomLeading)
                    ).blur(radius: 20)
                    .offset(x: -midX / 2, y: midY / 2 + 100)
                    .frame(width: width / 2 + 50)
                Circle()
                    .fill(
                        LinearGradient(colors: [colors[0], colors[1]],
                                             startPoint: .topTrailing, endPoint: .bottomLeading)
                    ).blur(radius: 12)
                    .offset(x: midX / 2 + 100, y: midY + 100)
                    .frame(width: width / 2 + 80)
            }
        }
    }
    
    @ViewBuilder
    func GlassGradiantTest() -> some View {
        ZStack {
            Rectangle().fill(LinearGradient(colors: [.indigo, .purple], startPoint: .top, endPoint: .bottom))
            RoundedRectangle(cornerRadius: 25)
                .fill(.white.opacity(0.5))
                .background(
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(lineWidth: 2)
                                        .fill(
                                            LinearGradient(colors: [
                                                .white, .white.opacity(0.5), .clear, .clear, .mint.opacity(0.5), .mint],
                                                           startPoint: .topLeading,
                                                           endPoint: .bottomTrailing))
                ).frame(width: 100, height: 100)
            TextField("", text: $text)
        }
        .ignoresSafeArea()
    }
    @ViewBuilder
    func ColorsVariationTest() -> some View {
        let colors: [String:Color] = [
            "yellow": .yellow,
            "orange": .orange,
            "salmon": Color(red: 1, green: 0.4, blue: 0),
            "red": .red,
            "scarlet": Color(red: 1, green: 0, blue: 0),
            "peach": Color(red: 1, green: 0.5, blue: 0.6),
            "lightPink": Color(red: 1, green: 0.5, blue: 0.8),
            "midPink": Color(red: 1, green: 0.4, blue: 0.8),
            "lightPurple": Color(red: 0.8, green: 0.5, blue: 1),
            "purple": .purple,
            "grape": Color(red: 0.7, green: 0, blue: 1),
            "violet": Color(red: 0.5, green: 0, blue: 1),
            "indigo": .indigo,
            "ultramarine": Color(red: 0.2, green: 0.2, blue: 0.6),
            "royalBlue": Color(red: 0, green: 0, blue: 1),
            "cobalt": Color(red: 0.2, green: 0.2, blue: 1),
            "blue": .blue,
            "cyan": .cyan,
            "teal": .teal,
            "mint": .mint,
            "green": .green,
            "sapphire": Color(red: 0, green: 0.6, blue: 0),
            "mossGreen": Color(red: 0.3, green: 0.5, blue: 0.3),
            "wasabi": Color(red: 0.5, green: 0.7, blue: 0.4),
            "gray": .gray,
            "black": .black,
            "darkBroun": Color(red: 0.3, green: 0.1, blue: 0),
            "navey": Color(red: 0, green: 0, blue: 0.4),
            "pansy": Color(red: 0.1, green: 0, blue: 0.3),
            "billiard": Color(red: 0, green: 0.2, blue: 0)
        ]

        ScrollView {
            VStack(spacing: 5) {
                ForEach(Array(colors.keys.sorted(by: < )), id:\.self) { key in
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)                            .fill(colors[key] ?? .white)
                            .frame(width: 200, height: 50)
                        Text(key)
                            .foregroundStyle(.white)
                    }
                }
            }
        }.scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    func GradientsTest() -> some View {
        let gradients: [[Color]] = [
        [.violet, .ultramarine, .navy],
        [.wasabi, .mossGreen, .billiard],
        [.purple, .indigo, .blue],
        [.mint, .cyan, .blue],
        [.yellow, .orange, .salmon],
        [.red, .purple],
        [.pink, .orange, .mint],
        [.mint, .blue, .purple],
        [.peach, .lightPink, .lightPurple],
        [.wasabi, .lightPurple, .peach],
        [.scarlet, .violet],
        [.lightPurple, .lightPurple, .lightPurple],
        [.wasabi, .wasabi, .wasabi]
        ]
        ScrollView {
            ForEach(gradients, id: \.self) { gradient in
                RoundedRectangle(cornerRadius: 10)
                    .fill(LinearGradient(colors: gradient,
                                         startPoint: .topLeading, endPoint: .topTrailing))
                    .frame(height:100)
                    .padding(.horizontal, 50)
            }
        }
    }
}

#Preview {
    Test()
}
