//
//  IncConsCatgModel.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/04.
//

import Foundation
import RealmSwift

class IncConsCategoryModel: Object, Identifiable {
    // 主キー
    @Persisted(primaryKey: true) var incConsCatgKey = ""
    
    // 項目主キー
    @Persisted var incConsSecKey = ""
    
    // 収入・支出カテゴリー名
    @Persisted var incConsCatgNm = ""
}
