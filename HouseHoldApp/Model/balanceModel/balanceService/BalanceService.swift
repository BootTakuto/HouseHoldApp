//
//  BalanceService.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/03.
//

import Foundation
import RealmSwift

class BalanceService: CommonService {

    func getBalData() -> Results<BalanceModel> {
        let results = realm.objects(BalanceModel.self)
        return results
    }
    
    /**残高情報登録
     @param 残高名
     @return --
     */
    func registBalance(balanceNm: String, assetsFlg: Bool) {
        let balance = BalanceModel()
        balance.balanceKey = UUID().uuidString
        balance.assetsFlg = assetsFlg
        balance.balanceNm = balanceNm
        balance.balanceAmt = 0
        try! realm.write() {
            realm.add(balance)
        }
    }
    
    /**残高を主キーで検索した結果を返す
     @param 残高主キー
     @return 取得結果(主キーを渡す時に空文字を制御するため、戻り値は強制unwrapする)
     */
    func getBalanceResult(balanceKey: String) -> BalanceModel {
        let result = realm.object(ofType: BalanceModel.self,
                                      forPrimaryKey: balanceKey)
        return result ?? BalanceModel()
    }
    
    /** 残高情報の削除
     @param 残高主キー
     @return --
     */
    func deleteBalance(balanceKey: String) {
        let result = realm.object(ofType: BalanceModel.self, forPrimaryKey: balanceKey)
        try! realm.write() {
            if let date = result {
                realm.delete(date)
            }
        }
    }
    
    /** 残高の合計金額を取得する(資産・負債に限らず)
     @param 資産or負債
     @return 残高合計
     */
    func getAssDebtBalTotal(assetsFlg: Bool) -> Int {
        let results = realm.objects(BalanceModel.self).where({$0.assetsFlg == assetsFlg})
        var total = 0
        if !results.isEmpty {
            results.forEach { result in
                total += result.balanceAmt
            }
        }
        return total
    }
}
