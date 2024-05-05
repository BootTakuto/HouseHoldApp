//
//  BalanceModel.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/03.
//

import Foundation
import RealmSwift

/** 資産残高、負債残高データ */
class BalanceModel: Object, Identifiable {
    // 主キー
    @Persisted(primaryKey: true) var balanceKey = UUID().uuidString
    // 資産フラグ
    @Persisted var assetsFlg = false
    // 残高名
    @Persisted var balanceNm = "不明"
    // 残高金額
    @Persisted var balanceAmt = 0
}
