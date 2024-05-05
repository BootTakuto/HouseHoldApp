//
//  incomeConsumeService.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/04.
//

import Foundation
import RealmSwift

class IncConSecCatgService: CommonService {
    
    /** 初期表示の収支カテゴリーの未分類カテゴリーキーを取得
     @param 収入フラグ
     @return 未分類カテゴリーキー
     */
    // ▼不要
    func getIncUnCatgCatgPKey(incFlg: Bool) -> String {
        let results = realm.objects(IncConsSectionModel.self).where({$0.incFlg == incFlg}).freeze()
        return results.count == 0 ? "" : results[0].incConsCatgOfSecList[0].incConsCatgKey
    }
    
    func getUnCatgCatgKey(incFlg: Bool) -> String {
        let results = realm.objects(IncConsSectionModel.self).where({$0.incFlg == incFlg}).freeze()
        return results.count == 0 ? "" : results[0].incConsCatgOfSecList[0].incConsCatgKey
    }
    
    /** 初期表示の収支セクションの未分類セクションキーを取得 
     @param 収入フラグ
     @return 未分類セクションキー
     */
    func getUnCatgSecKey(incFlg: Bool) -> String {
        let results = realm.objects(IncConsSectionModel.self).where({$0.incFlg == incFlg}).freeze()
        return results.count == 0 ? "" : results[0].incConsCatgOfSecList[0].incConsSecKey
    }
    
    
    /** 収入・支出項目の追加
     @param 収入フラグ
     @param 項目名
     @param カラーインデックス
     @param イメージ名
     @return --
     */
    func registIncConsSec(incFlg: Bool,
                          sectionNm: String,
                          colorIndex: Int,
                          imageNm: String) {
        let incConsSec = IncConsSectionModel()
        incConsSec.incConsSecKey = UUID().uuidString
        incConsSec.incFlg = incFlg
        incConsSec.incConsSecName = sectionNm
        incConsSec.incConsSecImage = imageNm
        incConsSec.incConsSecColorIndex = colorIndex
        
        let incConsCatg = IncConsCategoryModel()
        incConsCatg.incConsCatgKey = UUID().uuidString
        incConsCatg.incConsSecKey = incConsSec.incConsSecKey
        incConsCatg.incConsCatgNm = sectionNm
        
        var catgArray: Array<IncConsCategoryModel> = []
        catgArray.append(incConsCatg)
        
        incConsSec.incConsCatgOfSecList.append(objectsIn: catgArray)
        try! realm.write() {
            print(incConsSec.incConsSecKey)
            print(incConsSec.incConsCatgOfSecList.count)
            realm.add(incConsSec)
        }
    }
    
    /**項目ごとのカテゴリー名を取得する
     @param カテゴリー名
     @param 収入・支出項目データ主キー
     @return --
     */
    func registIncConsCatg(catgNm: String, incConsSecKey: String) {
        let incConsSec = realm.object(ofType: IncConsSectionModel.self, forPrimaryKey: incConsSecKey)
        
        let incConsCatg = IncConsCategoryModel()
        incConsCatg.incConsCatgKey = UUID().uuidString
        incConsCatg.incConsSecKey = incConsSecKey
        incConsCatg.incConsCatgNm = catgNm
        
        try! realm.write() {
            if let data = incConsSec {
                data.incConsCatgOfSecList.append(incConsCatg)
            }
        }
    }
    
    /**項目の主キーをもとにデータ削除　登録されている収支データに付与されている項目名を「未分類」に変更する
     @param 収支項目データ主キー
     @param 「未分類」項目主キー
     @param 「未分類」カテゴリー主キー
     @return --
     */
    func deleteIncConsData(incConsSecKey: String, unCatgSecKey: String, unCatgCatgKey: String, incFlg: Bool) {
        let incConsSec = realm.object(ofType: IncConsSectionModel.self, forPrimaryKey: incConsSecKey)
        let incConsCatg = realm.objects(IncConsCategoryModel.self).where({$0.incConsSecKey == incConsSecKey})
        // 削除に該当する項目が収支情報に登録されている場合「未分類で登録」
        let incConsResults = realm.objects(IncomeConsumeModel.self).where({$0.incFlg == incFlg && $0.incConsSecKey == incConsSecKey})
        incConsResults.forEach { result in
            // 削除する収支項目が一致する場合、未分類で登録する
            if result.incConsSecKey == incConsSecKey {
                try! realm.write() {
                    result.incConsSecKey = unCatgSecKey
                    result.incConsCatgKey = unCatgCatgKey
                }
            }
        }
        
        try! realm.write() {
            if let data = incConsSec {
                realm.delete(data)
                realm.delete(incConsCatg)
            }
        }
    }
    
    /** 選択した収入・支出カテゴリー名を取得する
     @param カテゴリー主キー
     @return カテゴリー名
     */
    func getCatgNm(catgKey: String) -> String {
        let catgResult = realm.object(ofType: IncConsCategoryModel.self, forPrimaryKey: catgKey)
        return catgResult?.incConsCatgNm ?? ""
    }
    
    /** インストール直後、1回のみ登録する。収支項目(サンプル用)
     *@param --
     *@return --
     */
    func registOnlyFirstIncConsSecCatg() {
        let registDatas: [FirstRegistIncCons] =
        [FirstRegistIncCons(incFlg: true, colorIndex: 16, imageNm: "questionmark", sectionNm: "未分類"),
         FirstRegistIncCons(incFlg: true, colorIndex: 19, imageNm: "yensign", sectionNm: "収入"),
         FirstRegistIncCons(incFlg: false, colorIndex: 3, imageNm: "questionmark", sectionNm: "未分類"),
         FirstRegistIncCons(incFlg: false, colorIndex: 0, imageNm: "fork.knife", sectionNm: "食費"),
         FirstRegistIncCons(incFlg: false, colorIndex: 1, imageNm: "tram.fill", sectionNm: "交通費"),
         FirstRegistIncCons(incFlg: false, colorIndex: 22, imageNm: "waterbottle.fill", sectionNm: "日用品"),
         FirstRegistIncCons(incFlg: false, colorIndex: 5, imageNm: "tshirt.fill", sectionNm: "衣服・美容"),
         FirstRegistIncCons(incFlg: false, colorIndex: 4, imageNm: "cross.case.fill", sectionNm: "医療費"),
         FirstRegistIncCons(incFlg: false, colorIndex: 20, imageNm: "antenna.radiowaves.left.and.right", sectionNm: "通信費"),
         FirstRegistIncCons(incFlg: false, colorIndex: 16, imageNm: "spigot.fill", sectionNm: "水道・光熱費"),
         FirstRegistIncCons(incFlg: false, colorIndex: 2, imageNm: "party.popper.fill", sectionNm: "娯楽費"),
         FirstRegistIncCons(incFlg: false, colorIndex: 15, imageNm: "figure.2", sectionNm: "交際費")]

        registDatas.forEach { obj in
            registIncConsSec(incFlg: obj.incFlg, sectionNm: obj.sectionNm, colorIndex: obj.colorIndex, imageNm: obj.imageNm)
        }
    }
}

struct FirstRegistIncCons {
    // 収入フラグ
    var incFlg: Bool
    // アイコンカラーインデックス
    var colorIndex: Int
    // アイコンイメージ名
    var imageNm: String
    // アイコン名
    var sectionNm: String
    
    init(incFlg: Bool, colorIndex: Int, imageNm: String, sectionNm: String) {
        self.incFlg = incFlg
        self.colorIndex = colorIndex
        self.imageNm = imageNm
        self.sectionNm = sectionNm
    }
}
