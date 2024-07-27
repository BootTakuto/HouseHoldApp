//
//  BudgetService.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/07/12.
//

import Foundation
import RealmSwift

class BudgetService: CommonService {
    
    let dateKeyFormat = "yyyyMM"
    
    /** 予算の登録
     @param 日付
     @param 金額
     */
    func registBudget(selectDate: Date, amount: String) {
        let budget = BudgetModel()
        budget.budgetDateKey = getStringDate(date: selectDate, format: dateKeyFormat)
        budget.budgetAmtTotal = Int(amount) ?? 0
        try! realm.write() {
            realm.add(budget)
        }
    }
    
    /** ,予算の更新
     @param 日付
     @param 金額
     */
    func updateBudget(selectDate: Date, amount: String) {
        let budget = realm.object(ofType: BudgetModel.self, forPrimaryKey: getStringDate(date: selectDate, format: dateKeyFormat))
        try! realm.write() {
            if let unWrapObj = budget {
                unWrapObj.budgetAmtTotal = Int(amount) ?? 0
            }
        }
    }
    
    /** 予算の取得
     @param 日付
     @return 予算オブジェクト
     */
    func getBudgetInfo(selectDate: Date) -> BudgetModel? {
        let dateKey = getStringDate(date: selectDate, format: dateKeyFormat)
        let object = realm.object(ofType: BudgetModel.self, forPrimaryKey: dateKey)
        return object ?? nil
    }
    
    /** 予算割合の取得
     @param 日付
     @return 予算の割合(double)
     */
    func getBudgetRate(selectDate: Date ) -> Double {
        let budgetObject = getBudgetInfo(selectDate: selectDate)
        let budgetAmtTotal: Double = Double(budgetObject != nil ? budgetObject!.budgetAmtTotal : 0)
        let incConsService = IncomeConsumeService()
        // 該当月の支出金額合計を取得する
        let consTotal: Double = Double(incConsService.getMonthIncOrConsAmtTotal(date: selectDate, houseHoldType: 1))
        var budgetRate: Double = 0.0
        if budgetAmtTotal > 0 {
            budgetRate = (consTotal / budgetAmtTotal) > 1 ? 0 : 1.0 - (consTotal / budgetAmtTotal)
        }
        return budgetRate
    }
}
