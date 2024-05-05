//
//  IncCons.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2023/12/06.
//

import Foundation
import RealmSwift

struct IncomeConsume {
    /**入金・出金項目の登録
     @param 入金項目か出金項目フラグ
     @param 項目名称
     @param イメージ名
     @param 色番号
     @return
     */
    func registIncConsSection(
        incOrConsFlg: Int,
        sectionNm: String,
        imageNm: String,
        colorIndex: Int
    ) {
        let realm = try! Realm()
        let incConsSec = IncConsSection()
        incConsSec.incConsSecKey = UUID().uuidString
        incConsSec.incOrConsFlg = incOrConsFlg
        incConsSec.incConsSecName = sectionNm
        incConsSec.incConsSecImage = imageNm
        incConsSec.incConsSecColorIndex = colorIndex
        
        try! realm.write {
            realm.add(incConsSec)
        }
    }
    
    /**入金・出金項目情報の登録
     @param
     @return  取得結果
     */
    func getIncConsSectionData(incOrConsFlg: Int) -> Results<IncConsSection> {
        let realm = try! Realm()
        let sectionData = realm.objects(IncConsSection.self).filter("incOrConsFlg == %@", incOrConsFlg).freeze()
        return sectionData
    }
    
    /**入金・出金項目情報の削除
     @param
     @return  取得結果
     */
}
