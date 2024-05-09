//
//  BalanceModel.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/03.
//

import Foundation
import RealmSwift

/** 残高データ */
class BalanceModel: Object, Identifiable {
    // 主キー
    @Persisted(primaryKey: true) var balanceKey = ""
    // カラーインデックス
    @Persisted var colorIndex = 0
    // 残高名
    @Persisted var balanceNm = "不明"
    // 残高金額
    @Persisted var balanceAmt = 0
}
