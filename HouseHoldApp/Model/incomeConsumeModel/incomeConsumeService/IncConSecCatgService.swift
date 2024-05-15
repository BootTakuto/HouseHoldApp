//
//  incomeConsumeService.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/04.
//

import Foundation
import RealmSwift

class IncConSecCatgService: CommonService {
    
    /** 収入・支出・残高操作の項目データを取得する
     @param 家計タイプ
     @return 収支項目リスト
     */
    func getIncConsSec(houseHoldType: Int) -> Results<IncConsSectionModel> {
        @ObservedResults(IncConsSectionModel.self, where: {$0.houseHoldType == houseHoldType}) var results
        return results
    }
    
    /** 収入・支出項目の登録
     @param 家計タイプ
     @param 項目名
     @param カラーインデックス
     @param イメージ名
     @return --
     */
    func registIncConsSec(houseHoldType: Int,
                          sectionNm: String,
                          colorIndex: Int,
                          imageNm: String) {
        let incConsSec = IncConsSectionModel()
        incConsSec.incConsSecKey = UUID().uuidString
        incConsSec.houseHoldType = houseHoldType
        incConsSec.incConsSecName = sectionNm
        incConsSec.incConsSecImage = imageNm
        incConsSec.incConsSecColorIndex = colorIndex
        
        var catgArray: Array<IncConsCategoryModel> = []
        if houseHoldType != 2 {
            let incConsCatg = IncConsCategoryModel()
            incConsCatg.incConsCatgKey = UUID().uuidString
            incConsCatg.incConsSecKey = incConsSec.incConsSecKey
            incConsCatg.incConsCatgNm = sectionNm
            catgArray.append(incConsCatg)
        }
        incConsSec.incConsCatgOfSecList.append(objectsIn: catgArray)
        try! realm.write() {
            realm.add(incConsSec)
        }
    }
    
    /** 初期表示の収支セクションの未分類セクションキーを取得 
     @param 収入フラグ
     @return 未分類セクションキー
     */
    func getUnCatgSecKey(houseHoldType: Int) -> String {
        @ObservedResults(IncConsSectionModel.self, where: {$0.houseHoldType == houseHoldType}) var results
        return results.isEmpty ? "" : results[0].incConsSecKey
    }
    
    /** 初期表示の収支カテゴリーの未分類カテゴリーキーを取得
     @param 収入フラグ
     @return 未分類カテゴリーキー
     */
    func getUnCatgCatgKey(houseHoldType: Int) -> String {
        @ObservedResults(IncConsSectionModel.self, where: {$0.houseHoldType == houseHoldType}) var results
        return results[0].incConsCatgOfSecList.isEmpty ? "" : results[0].incConsCatgOfSecList[0].incConsCatgKey
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
    
    /** 選択した収入・支出カテゴリー名を取得する
     @param カテゴリー主キー
     @return カテゴリー名
     */
    func getCatgNm(catgKey: String) -> String {
        let catgResult = realm.object(ofType: IncConsCategoryModel.self, forPrimaryKey: catgKey)
        return catgResult?.incConsCatgNm ?? ""
    }
    
    func deleteAll() {
        let result1 = realm.objects(IncConsSectionModel.self)
        let result2 = realm.objects(IncConsCategoryModel.self)
        try! realm.write {
            result1.forEach { result in
                realm.delete(result)
            }
            result2.forEach { result in
                realm.delete(result)
            }
        }
    }
    
    /** インストール直後、1回のみ登録する。収支項目(サンプル用)
     *@param --
     *@return --
     */
    func registOnlyFirstIncConsSecCatg() {
        let registDatas: [FirstRegistIncCons] =
        [FirstRegistIncCons(houseHoldType: 0, colorIndex: 16, imageNm: "questionmark", sectionNm: "未分類"),
         FirstRegistIncCons(houseHoldType: 0, colorIndex: 19, imageNm: "yensign", sectionNm: "収入"),
         FirstRegistIncCons(houseHoldType: 1, colorIndex: 3, imageNm: "questionmark", sectionNm: "未分類"),
         FirstRegistIncCons(houseHoldType: 1, colorIndex: 0, imageNm: "fork.knife", sectionNm: "食費"),
         FirstRegistIncCons(houseHoldType: 1, colorIndex: 1, imageNm: "tram.fill", sectionNm: "交通費"),
         FirstRegistIncCons(houseHoldType: 1, colorIndex: 22, imageNm: "waterbottle.fill", sectionNm: "日用品"),
         FirstRegistIncCons(houseHoldType: 1, colorIndex: 5, imageNm: "tshirt.fill", sectionNm: "衣服・美容"),
         FirstRegistIncCons(houseHoldType: 1, colorIndex: 4, imageNm: "cross.case.fill", sectionNm: "医療費"),
         FirstRegistIncCons(houseHoldType: 1, colorIndex: 20, imageNm: "antenna.radiowaves.left.and.right", sectionNm: "通信費"),
         FirstRegistIncCons(houseHoldType: 1, colorIndex: 16, imageNm: "spigot.fill", sectionNm: "水道・光熱費"),
         FirstRegistIncCons(houseHoldType: 1, colorIndex: 2, imageNm: "party.popper.fill", sectionNm: "娯楽費"),
         FirstRegistIncCons(houseHoldType: 1, colorIndex: 15, imageNm: "figure.2", sectionNm: "交際費"),
         FirstRegistIncCons(houseHoldType: 1, colorIndex: 13, imageNm: "book", sectionNm: "教育費")
        ]
        
        registDatas.forEach { obj in
            registIncConsSec(houseHoldType: obj.houseHoldType, sectionNm: obj.sectionNm, colorIndex: obj.colorIndex, imageNm: obj.imageNm)
        }
    }
}

struct FirstRegistIncCons {
    // 収入フラグ
    var houseHoldType: Int
    // アイコンカラーインデックス
    var colorIndex: Int
    // アイコンイメージ名
    var imageNm: String
    // アイコン名
    var sectionNm: String
    
    init(houseHoldType: Int, colorIndex: Int, imageNm: String, sectionNm: String) {
        self.houseHoldType = houseHoldType
        self.colorIndex = colorIndex
        self.imageNm = imageNm
        self.sectionNm = sectionNm
    }
}
