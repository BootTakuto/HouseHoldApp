//
//  RegistIncConsObject.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/05/16.
//

import Foundation

/*　収入・支出登録用情報オブジェクト　*/
struct IncConsAmtForm {
    // 残高キー
    var balKey: String
    // 金額
    var amount: String
    // 残高増減フラグ　true:増やす, false:減らす
    var isIncrease: Bool
    
    init(balKey: String, amount: String, isIncrease: Bool) {
        self.balKey = balKey
        self.amount = amount
        self.isIncrease = isIncrease
    }
}
