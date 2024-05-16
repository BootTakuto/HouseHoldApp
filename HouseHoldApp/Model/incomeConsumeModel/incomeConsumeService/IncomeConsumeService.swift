//
//  IncomeConsumeService.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/07.
//

import Foundation
import RealmSwift
import SwiftUI

class IncomeConsumeService: CommonService {
    
    let dateFormatter = "yyyyMMdd"
    let calendarService = CalendarService()
    
    /** 収支登録　残高と連携しない
     @param 残高データ主キー
     @param 収入登録フラグ
     @param 収入・支出カテゴリー主キー
     @param 金額
     @param 日付
     @param メモ
     @return 成功・失敗ステータス
     */
    func registIncConsNotLikBal(houseHoldType: Int,
                                incConsSecKey: String,
                                incConsCatgKey: String,
                                inputAmt: Int,
                                incConsDate: Date,
                                memo: String) -> PopUpStatus {
        let resultSize = realm.objects(IncomeConsumeModel.self).count
        let incConsModel = IncomeConsumeModel()
        incConsModel.incConsKey = UUID().uuidString
        incConsModel.houseHoldType = houseHoldType
        incConsModel.incConsSecKey = incConsSecKey
        incConsModel.incConsCatgKey = incConsCatgKey
        incConsModel.incConsAmtValue = inputAmt
        incConsModel.incConsDate = getStringDate(date: incConsDate, format: dateFormatter)
        incConsModel.memo = memo
        try! realm.write() {
            realm.add(incConsModel)
        }
        return resultSize < realm.objects(IncomeConsumeModel.self).count ? .success : .failed
    }
    
    /** 収支登録　残高と連携
     @param 残高データ主キー
     @param 収入登録フラグ
     @param 収入・支出カテゴリー主キー
     @param 金額
     @param 日付
     @param メモ
     @return --
     */
    func registIncConsLinkBal(balKeyArray: [String],
                              registAmtFormArray: [IncConsAmtForm],
                              houseHoldType: Int,
                              incConsSecKey: String,
                              incConsCatgKey: String,
                              incConsDate: Date,
                              memo: String) -> PopUpStatus {
        let resultSize = realm.objects(IncomeConsumeModel.self).count
        // 金額配列[String]を[Int]に変換
        var amountIntArray: [Int] = []
        registAmtFormArray.forEach { data in
            if data.isIncrease {
                amountIntArray.append(Int(data.amount) ?? 0)
            } else {
                let decAmt = Int(data.amount) ?? 0
                amountIntArray.append(decAmt * -1)
            }
        }
        print(amountIntArray)
        // 合計金額
        var incConsAmtValue = 0
        amountIntArray.forEach { amt in
            incConsAmtValue += amt
        }
        let incConsModel = IncomeConsumeModel()
        incConsModel.incConsKey = UUID().uuidString
        incConsModel.houseHoldType = houseHoldType
        incConsModel.balanceKeyList.append(objectsIn: balKeyArray)
        incConsModel.incConsAmtList.append(objectsIn: amountIntArray)
        incConsModel.incConsSecKey = incConsSecKey
        incConsModel.incConsCatgKey = incConsCatgKey
        incConsModel.incConsAmtValue = incConsAmtValue
        incConsModel.incConsDate = getStringDate(date: incConsDate, format: dateFormatter)
        incConsModel.memo = memo
        try! realm.write() {
            realm.add(incConsModel)
            balKeyArray.indices.forEach { index in
                let wrapResult = realm.object(ofType: BalanceModel.self, forPrimaryKey: balKeyArray[index])
                if let unWrapResult = wrapResult {
                    if houseHoldType == 0 || houseHoldType == 2 {
                        unWrapResult.balanceAmt += amountIntArray[index]
                    } else if houseHoldType == 1 {
                        unWrapResult.balanceAmt -= amountIntArray[index]
                    }
                }
            }
        }
        return resultSize < realm.objects(IncomeConsumeModel.self).count ? .success : .failed
    }
    
    /** 主キーを基にオブジェクトを取得
     @param 収支主キー
     @return 取得結果
     */
    func getIncConsObject(pkey: String) -> IncomeConsumeModel {
        let result = realm.object(ofType: IncomeConsumeModel.self, forPrimaryKey: pkey)
        return result ?? IncomeConsumeModel()
    }

    /** 収支情報を削除
     @param 収支情報データ主キー
     @return --
     */
    func deleteIncConsData(incConsKey: String) {
        let result = realm.object(ofType: IncomeConsumeModel.self, forPrimaryKey: incConsKey)
        try! realm.write() {
            if let data = result {
                realm.delete(data)
            }
        }
    }
    
    /** 表示条件を基にkey: 日付(yyyyMMdd), value: 取得結果listの辞書型収支情報を取得する
     @param 取得条件①：全収支情報
     @param 取得条件②：収入or支出情報のみ
     @param 現在日付
     @return key: 日付(yyyyMMdd), value: 取得結果listの辞書型収支情報
     */
    func getIncConsPerDate(all: Bool, incFlg: Bool, date: Date) -> [String: Results<IncomeConsumeModel>] {
        var resultDictionary = [String: Results<IncomeConsumeModel>]()
        // 現在日付を基に月ごとの全日付を配列で取得する
        let dateArray = getAllDayOfMonth(date: date)
        // 日付に合致するものをdictionaryに格納
        dateArray.forEach { dateInt in
            let dateStr = String(dateInt)
            if all {
                let results = realm.objects(IncomeConsumeModel.self).where({$0.incConsDate == dateStr}).freeze()
                if !results.isEmpty {
                    resultDictionary[dateStr] = results
                }
            } else {
                let results = realm.objects(IncomeConsumeModel.self).where({$0.houseHoldType == 0 && $0.incConsDate == dateStr}).freeze()
                if !results.isEmpty {
                    resultDictionary[dateStr] = results
                }
            }
        }
        return resultDictionary
    }
    
    /** 日付を基に収入・支出データを取得する
     @param 現在日付
     @param 収入フラグ true: 収入, false: 支出
     @return 合計金額
     */
    func getIncOrConsAmtTotal(date: Date, incFlg: Bool) -> Int {
        var total = 0
        let dateArray = getAllDayOfMonth(date: date)
        dateArray.forEach { dateInt in
            let dateStr = String(dateInt)
            let results = realm.objects(IncomeConsumeModel.self).where({$0.houseHoldType == 0 && $0.incConsDate == dateStr})
            if !results.isEmpty {
                results.forEach { result in
                    total += result.incConsAmtValue
                }
            }
        }
        return total
    }
    
    /** 日毎の入出金合計金額を取得する
     @param 日付(String)
     @param 収入フラグ
     @return 日毎の入出金合計金額
     */
    func getIncConsAmtTotalPerDay(dateStr: String, incFlg: Bool) -> Int {
        var total = 0
        let results = realm.objects(IncomeConsumeModel.self).where({$0.houseHoldType == 0 && $0.incConsDate == dateStr})
        results.forEach { result in
            total += result.incConsAmtValue
        }
        return total
    }
    
    /** 日毎の収支情報が存在するか(カレンダーの収支情報の表示有無で使用)
     @param 日付(String)
     @param 収入・支出フラグ
     @return 存在するか否か
     */
    func isExsistIncConsData(dateStr: String, incFlg: Bool) -> Bool {
        var exsistFlg = false
        let results = realm.objects(IncomeConsumeModel.self).where({$0.houseHoldType == 0 && $0.incConsDate == dateStr})
        exsistFlg = !results.isEmpty
        return exsistFlg
    }
    
    /** 月の全日付を取得する
     @param 現在日付
     @return 月の全日付配列を返却
     */
    func getAllDayOfMonth(date: Date) -> [Int] {
        let calendarService = CalendarService()
        let firstDay = calendarService.getFirstDayOfMonth(date: date)
        let firstDayStr = getStringDate(date: firstDay, format: dateFormatter)
        let endDay = calendarService.getEndDayOfMonth(date: date)
        let endDayStr = getStringDate(date: endDay, format: dateFormatter)
        // 月の全データを取得する
        var firstDayInt = Int(firstDayStr) ?? 0
        let endDayInt = Int(endDayStr) ?? 0
        var allDayOfMonth = [Int]()
        
        while firstDayInt <= endDayInt {
            allDayOfMonth.append(firstDayInt)
            firstDayInt += 1
        }
        
        return allDayOfMonth
    }
    
    /** 収入・支出項目データを主キーを基に取得
     @param 収入・支出項目主キー
     @return 収入・支出項目オブジェクト
     */
    func getIncConsSec(pkey: String) -> IncConsSectionModel {
        let result = realm.object(ofType: IncConsSectionModel.self, forPrimaryKey: pkey)
        return result ?? IncConsSectionModel()
    }
    
    /** 収入・支出カテゴリーデータを主キーを基に取得
     @param 収入・支出カテゴリー主キー
     @return 収入・支出カテゴリーオブジェクト
     */
    func getIncConsCatg(pkey: String) -> IncConsCategoryModel {
        let result = realm.object(ofType: IncConsCategoryModel.self, forPrimaryKey: pkey)
        return result ?? IncConsCategoryModel()
    }
    
    /** 残高データを主キーを基に取得
     @param 残高主キー
     @return 残高オブジェクト
     */
    func getBalanceObj(pkey: String) -> BalanceModel {
        var result = realm.object(ofType: BalanceModel.self, forPrimaryKey: pkey)
        if result == nil {
            result = BalanceModel()
            result!.balanceNm = "不明(削除の可能性)"
        }
        return result!
    }
    
    /** 日付テキストの加工
     @param 日付テキスト(yyyyMMdd)
     @return 加工された日付テキスト
     */
    func treatDateText(dateStr: String) -> String {
        // ex) 20240210
        var result = dateStr
        // ex) 2024年0210
        result = insertText(targetText: result, insertText: "/", prefix: 4)
        // ex) 2024年02月10
        result = insertText(targetText: result, insertText: "/", prefix: 7)
        // ex) 2024年02月10日
        return result
    }
    
    /** 入力中の収支金額の合計を取得
     @param 入力金額の配列
     @retrun 入力金額の合計
     */
    func getInputAmtTotal(inputAmts: [Int]) -> Int {
        var inputAmtTotal = 0
        if !inputAmts.isEmpty {
            inputAmts.forEach { amt in
                inputAmtTotal += amt
            }
        }
        return inputAmtTotal
    }
    
    /** 日毎の収支、収入、支出合計を取得する
     @param 日付(月の同日を取得している)
     @return [key:  日付, value:  日毎の収支合計、日毎の収入合計、日毎の支出合計の配列]
     */
    func getIncConsTotalPerDate(selectDate: Date) -> [String: [Int]] {
        // 該当月を含んだ日付
        let dates = getAllDayOfMonth(date: selectDate)
        var results: [String: [Int]] = [:]
        dates.forEach { date in
            let dateStr = String(date)
            // ▼該当日の収入、支出、収支合計を格納配列
            var amtTotalsPerDate: [Int] = []
            // ▼収入関連
            let incResults = realm.objects(IncomeConsumeModel.self).where({$0.incConsDate == dateStr && $0.houseHoldType  == 0})
            var incTotal = 0
            // ▼支出関連
            let consResults = realm.objects(IncomeConsumeModel.self).where({$0.incConsDate == dateStr && $0.houseHoldType == 1})
            var consTotal = 0
            if !incResults.isEmpty || !consResults.isEmpty {
                incResults.forEach { result in
                    incTotal += result.incConsAmtValue
                }
                amtTotalsPerDate.append(incTotal)
                consResults.forEach { result in
                    consTotal -= result.incConsAmtValue
                }
                amtTotalsPerDate.append(consTotal)
                // ▼収支関連
                amtTotalsPerDate.append(incTotal - consTotal)
                results[dateStr] = amtTotalsPerDate
            }
        }
        return results
    }
    
    func getIncConsPerDate(selectDate: Date) -> [String: Results<IncomeConsumeModel>] {
        var dictionary: [String: Results<IncomeConsumeModel>]  = [:]
        let datesArray: [Int] = getAllDayOfMonth(date: selectDate)
        datesArray.forEach { dateInt in
            let dateStr = String(dateInt)
            let incConsResults = realm.objects(IncomeConsumeModel.self).where({$0.incConsDate == dateStr})
            if !incConsResults.isEmpty {
                dictionary[dateStr] = incConsResults
            }
        }
        return dictionary
    }
    
    /** 日毎の支出または収入の合計金額を取得
     @param 日付(Date型)
     @param 収入・支出フラグ
     @return 日毎の支出または収入の合計金額
     */
    func getIncConsTotalPerDay(day: Date, incFlg: Bool) -> Int {
        let dateStr = getStringDate(date: day, format: dateFormatter)
        let results = realm.objects(IncomeConsumeModel.self).where({$0.houseHoldType == 0 && $0.incConsDate == dateStr})
        var amtTotalPerDay = 0
        results.forEach { result in
            amtTotalPerDay += result.incConsAmtValue
        }
        return amtTotalPerDay
    }
    
    /** 日毎の収入または支出の取引の有無を取得
     @param 日付(Date型)
     @param 収入・支出フラグ
     @return 日毎の収入または支出の有無
     */
    func isExsistIncConsData(day: Date, incFlg: Bool) -> Bool {
        let dateStr = getStringDate(date: day, format: dateFormatter)
        let results = realm.objects(IncomeConsumeModel.self).where({$0.houseHoldType == 0 && $0.incConsDate == dateStr})
        return !results.isEmpty
    }
    
    /* チャート表示用の収入・支出情報を取得 収支項目ごとのカラーインデックスと金額を取得
     @param incFlg
     @return Dicionary[収支項目主キー : 項目ごとの金額合計]
     */
    func getIncConsDataForChart(incFlg: Bool, selectDate: Date) -> [String: Int] {
        let dates = getAllDayOfMonth(date: selectDate)
        var dicForChart = [String : Int]()
        dates.forEach { date in
            var results = realm.objects(IncomeConsumeModel.self).where({$0.houseHoldType == 0 && $0.incConsDate == String(date)})
            results.forEach { result in
                let incConsSecKey = result.incConsSecKey
                if dicForChart[incConsSecKey] != nil {
                    dicForChart[incConsSecKey]! += result.incConsAmtValue
                } else {
                    dicForChart[incConsSecKey] = result.incConsAmtValue
                }
            }
        }
        return dicForChart
    }
    
    /** 収支項目からカラーインデックスを取得する
     @param 収支項目主キー
     @return カラーインデックス(ない場合は24: .gray)
     */
    func getColorIndex(incConsSecKey: String) -> Int {
        let incConsSecResult = realm.object(ofType: IncConsSectionModel.self, forPrimaryKey: incConsSecKey)
        return incConsSecResult?.incConsSecColorIndex ?? 24
    }
    
    /* 月別 収入・支出チャート用のデータを取得
     @param 日付
     @param 何ヶ月分の作成か(viewのサイズによって作成量を調整したい)
     @return 月別 収入・支出チャートデータ
     */
    func getIncConsChartEntry(selectDate: Date, makeSize: Int) -> [IncConsChartEntry] {
        // 返却用チャート配列
        var returnArray: [IncConsChartEntry] = []
        // dateから一年前を取得する
        let aYearAgo = calendarService.xAfterMonth(date: selectDate, value: -makeSize)
        var months: [Date] = [aYearAgo]
        while months.count <= makeSize {
            months.append(calendarService.nextMonth(date: months.last!))
        }
        months.forEach { date in
            let incTotalPerMonth = getIncOrConsAmtTotal(date: date, incFlg: true)
            let consTotalPerMonth = getIncOrConsAmtTotal(date: date, incFlg: false)
            let totalGap = incTotalPerMonth - consTotalPerMonth
            let monthStr = getStringDate(date: date, format: "yy年M月")
            returnArray.append(.init(type: "収入額", month: monthStr, amount: incTotalPerMonth, color: .blue))
            returnArray.append(.init(type: "支出額", month: monthStr, amount: consTotalPerMonth, color: .red))
            returnArray.append(.init(type: "収支合計", month: monthStr, amount: totalGap, color: .changeableText))
        }
        return returnArray
    }
    
    /* 残高連携情報作成で複数選択を検知する
     @param 連携残高配列
     @param 残高キー
     @return 残高がすでに含まれているか
     */
    func isExsistRegistForm(array: [IncConsAmtForm], balKey: String) -> Bool {
        var isExist = false
        array.forEach { data in
            isExist = data.balKey == balKey
        }
        return isExist
    }
    
    /* 残高連携情報の配列で該当残高キーを含むインデックスを取得する
     @param 連携残高配列
     @param 残高キー
     @return 残高キーが含まれる配列インデックス
     */
    func getIndexAmtFormArray(array: [IncConsAmtForm], balKey: String) -> Int {
        var containIndex = 0
        array.indices.forEach { index in
            containIndex = array[index].balKey == balKey ? index : 0
        }
        return containIndex
    }
    
}
