//
//  GadientAccentcColors.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/01.
//

import Foundation
import SwiftUI

/** 背景色 */
struct GradientAccentcColors {
    static let gradients: [[Color]] = [
        // 単色
        [.yellow, .yellow],
        [.orange, .orange],
        [.red, .red],
        [.peach, .peach],
        [.lightPurple, .lightPurple],
        [.purple, .purple],
        [.navy, .navy],
        [.blue, .blue],
        [.cyan, .cyan],
        [.mint, .mint],
        [.green, .green],
        [.mossGreen, .mossGreen],
        // 青系
        [.mint, .blue],
        [.blue, .violet],
        [.indigo, .navy],
        // 緑系
        [.mint, .green],
        [.green, .mossGreen],
        [.mossGreen, .billiard],
        // 柑橘色
        [.yellow, .salmon],
        [.orange, .pink],
        [.red, .blood],
        // 淡い系
        [.lightPink, .lightPurple],
        [.peach, .pink],
        [.pink, .violet]
    ]
}

#Preview {
    @State var popUpFlg = false
    return SelectAccentColorPopUpView(accentColors: [.white, .black],
                                      popUpFlg: $popUpFlg)
}

