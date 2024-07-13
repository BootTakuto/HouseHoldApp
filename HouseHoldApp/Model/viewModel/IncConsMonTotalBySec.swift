//
//  IncConsMonTotalBySec.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/07/05.
//

import Foundation
struct IncConsMonTotalBySec {
    // 収支項目オブジェクト
    var incConsSecObj: IncConsSectionModel
    // 該当月の項目別金額合計
    var amtTotalBySecMon: Int
    init(incConsSecObj: IncConsSectionModel, amtTotalBySecMon: Int) {
        self.incConsSecObj = incConsSecObj
        self.amtTotalBySecMon = amtTotalBySecMon
    }
}
