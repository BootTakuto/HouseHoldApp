//
//  SampleView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/11.
//

import SwiftUI

struct SampleView: View {
    let general = GeneralComponentView()
    var body: some View {
        ZStack {
            
            let bdcolors: [Color] = [.pink, .purple, .orange]
            //            let colors: [Color] = [.navy, .cobalt, .purple, .cyan]
            //            general.GradientBackGround(colors: colors)
            //            general.BackGround(colors: colors)
            //            general.BlurDotBackGround(colors: bdcolors)
            //            general.BlurDotBackGround2(colors: bdcolors)
            ScrollView {
                VStack {
                    Text("▼Icon")
                    general.RoundedIcon(radius: 15, color: bdcolors[0],
                                        image: "arrow.down.left.arrow.up.right", text: "text")
                    .frame(width: 50, height: 50)
                    Text("▼GradientCard")
                    general.GradientCard(colors: bdcolors, radius: 20)
                        .frame(width: 250, height: 100)
                    Text("▼CustomText")
                    general.ButtonGradientCircle(colors: [.pink, .purple])
                        .frame(width: 50)
                }.padding(.horizontal, 50)
            }.scrollIndicators(.hidden)
        }
    }
}

#Preview {
    SampleView()
}
