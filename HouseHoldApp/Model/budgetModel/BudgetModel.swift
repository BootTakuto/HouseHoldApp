//
//  BudgetMode.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/05/20.
//

import Foundation
import RealmSwift

class BudgetModel: Object, Identifiable {
    // 主キー(日付)
    @Persisted(primaryKey: true) var budgetDateKey = ""
    // 予算額合計
    @Persisted var budgetAmtTotal = 0
}

