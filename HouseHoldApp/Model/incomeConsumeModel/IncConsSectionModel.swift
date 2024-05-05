//
//  IncConsSectionModel.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/04.
//

import Foundation
import RealmSwift

class IncConsSectionModel: Object, Identifiable {
    // 主キー
    @Persisted(primaryKey: true) var incConsSecKey = ""
    
    // 収入フラグ
    @Persisted var incFlg = true
    
    // 収入・支出項目名
    @Persisted var incConsSecName = ""
    
    // 収入・支出項目イメージ
    @Persisted var incConsSecImage = ""
    
    // 収入・支出項目カラー
    @Persisted var incConsSecColorIndex = 0
    
    // 収入・支出項目が含むカテゴリーのリスト
    @Persisted var incConsCatgOfSecList = RealmSwift.List<IncConsCategoryModel>()
}
