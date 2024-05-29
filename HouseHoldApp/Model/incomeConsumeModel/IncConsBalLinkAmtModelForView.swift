//
//  RegistIncConsObject.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/05/16.
//

import Foundation

// RealmオブジェクトはSwiftUIで変更を感知できないため、View用の構造体を作成
// 登録するタイミングでIncConsBalLinkAmtModelにマッピング
struct IncConsBalLinkAmtModelForView {
    // 残高キー
    var balanceKey: String
    // 金額
    var incConsAmt: String
    // 残高増減フラグ　true:増やす, false:減らす
    var isIncreaseBal: Bool
    
    init(balanceKey: String, incConsAmt: String, isIncreaseBal: Bool) {
        self.balanceKey = balanceKey
        self.incConsAmt = incConsAmt
        self.isIncreaseBal = isIncreaseBal
    }
}
