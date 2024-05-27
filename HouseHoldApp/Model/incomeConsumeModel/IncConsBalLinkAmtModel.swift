//
//  IncConsBalLinkAmtModel.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/05/25.
//

import Foundation
import RealmSwift

// 残高に連携される金額を格納するオブジェクト
class IncConsBalLinkAmtModel: Object {
    // 連携された残高主キー
    @Persisted var balanceKey: String = ""
    // 残高に連携される金額
    @Persisted var incConsAmt: String = "0"
    // 連携された残高に金額を増減するか
    @Persisted var isIncreaseBal: Bool = true
}

// RealmオブジェクトはSwiftUIで変更を感知できないため、View用の構造体を作成
// 登録するタイミングでIncConsBalLinkAmtModelにマッピング
struct IncConsBalLinkAmtModelForView {
    var balanceKey = ""
    var incConsAmt = "0"
    var isIncreaseBal = true
}
