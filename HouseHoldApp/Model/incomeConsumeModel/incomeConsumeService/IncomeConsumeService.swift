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
                              linkBalAmtArray: [IncConsBalLinkAmtModelForView],
                              houseHoldType: Int,
                              incConsSecKey: String,
                              incConsCatgKey: String,
                              incConsDate: Date,
                              memo: String) -> PopUpStatus {
        let resultSize = realm.objects(IncomeConsumeModel.self).count
        let incConsModel = IncomeConsumeModel()
        // 主キー
        incConsModel.incConsKey = UUID().uuidString
        // 家計タイプ
        incConsModel.houseHoldType = houseHoldType
        // 収支項目主キー
        incConsModel.incConsSecKey = incConsSecKey
        // 収支カテゴリー主キー
        incConsModel.incConsCatgKey = incConsCatgKey
        // 残高リンク情報
        linkBalAmtArray.forEach {obj in
            let balLinkAmt = IncConsBalLinkAmtModel()
            balLinkAmt.balanceKey = obj.balanceKey
            balLinkAmt.incConsAmt = obj.incConsAmt
            balLinkAmt.isIncreaseBal = obj.isIncreaseBal
            incConsModel.balLinkAmtList.append(balLinkAmt)
        }
        // 収支金額合計
        incConsModel.balLinkAmtList.forEach { obj in
            if houseHoldType != 2 {
                incConsModel.incConsAmtValue += Int(obj.incConsAmt) ?? 0
            } else {
                if obj.isIncreaseBal {
                    incConsModel.incConsAmtValue += Int(obj.incConsAmt) ?? 0
                } else {
                    incConsModel.incConsAmtValue -= Int(obj.incConsAmt) ?? 0
                }
            }
        }
        // 日付(yyyyMMddに変換)
        incConsModel.incConsDate = getStringDate(date: incConsDate, format: dateFormatter)
        // メモ
        incConsModel.memo = memo
        // 登録処理
        try! realm.write() {
            // 収支情報登録
            realm.add(incConsModel)
            // 残高金額を増減
            incConsModel.balLinkAmtList.forEach { obj in
                let wrapResult = realm.object(ofType: BalanceModel.self, forPrimaryKey: obj.balanceKey)
                if let unWrapResult = wrapResult {
                    if obj.isIncreaseBal {
                        unWrapResult.balanceAmt += Int(obj.incConsAmt) ?? 0
                    } else {
                        unWrapResult.balanceAmt -= Int(obj.incConsAmt) ?? 0
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
    
    /** 日付を基に月間の収入・支出合計金額を取得する
     @param 現在日付
     @param 収入フラグ true: 収入, false: 支出
     @return 合計金額
     */
    func getMonthIncOrConsAmtTotal(date: Date, houseHoldType: Int) -> Int {
        let str_yyyyMM = getStringDate(date: date, format: "yyyyMM")
        let total = realm.objects(IncomeConsumeModel.self)
            .where({$0.houseHoldType == houseHoldType})
            .filter("incConsDate LIKE %@", "*\(str_yyyyMM)*")
            .sum(ofProperty: "incConsAmtValue") ?? 0
        return total
    }
    
    /** 年間の収入・支出合計金額を取得する
     @param 現在日付
     @param 収入フラグ true: 収入, false: 支出
     @return 合計金額
     */
    func getYearIncOrConsAmtTotal(year: Int, houseHoldType: Int) -> Int {
        let str_yyyy = String(year)
        let total = realm.objects(IncomeConsumeModel.self)
            .where({$0.houseHoldType == houseHoldType})
            .filter("incConsDate LIKE %@", "*\(str_yyyy)*")
            .sum(ofProperty: "incConsAmtValue") ?? 0
        return total
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
    
    func getIncConsPerDate(selectDate: Date, listType: Int) -> [String: Results<IncomeConsumeModel>] {
        var dictionary: [String: Results<IncomeConsumeModel>]  = [:]
        let datesArray: [Int] = getAllDayOfMonth(date: selectDate)
        datesArray.forEach { dateInt in
            let dateStr = String(dateInt)
            var incConsResults: Results<IncomeConsumeModel>
            switch listType {
            case 0:
                incConsResults = realm.objects(IncomeConsumeModel.self).where({$0.incConsDate == dateStr})
            case 1:
                incConsResults = realm.objects(IncomeConsumeModel.self)
                    .where({$0.incConsDate == dateStr && $0.houseHoldType != 2})
            case 2:
                incConsResults = realm.objects(IncomeConsumeModel.self)
                    .where({$0.incConsDate == dateStr && $0.houseHoldType == 0})
            case 3:
                incConsResults = realm.objects(IncomeConsumeModel.self)
                    .where({$0.incConsDate == dateStr && $0.houseHoldType == 1})
            case 4:
                incConsResults = realm.objects(IncomeConsumeModel.self)
                    .where({$0.incConsDate == dateStr && $0.houseHoldType == 2})
            default:
                incConsResults = realm.objects(IncomeConsumeModel.self).where({$0.incConsDate == dateStr})
            }
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
    func getIncConsTotalPerDay(day: Date, houseHoldType: Int) -> Int {
        let dateStr = getStringDate(date: day, format: dateFormatter)
        let results = realm.objects(IncomeConsumeModel.self).where({$0.houseHoldType == houseHoldType && $0.incConsDate == dateStr})
        var amtTotalPerDay = 0
        results.forEach { result in
            amtTotalPerDay += result.incConsAmtValue
        }
        return amtTotalPerDay
    }
    
    /** 当月の収入または支出の取引の有無を取得
     @param
     @param
     */
    func isExistIncConsMonth(refDate: Date) -> Bool {
        let str_yyyyMM = getStringDate(date: refDate, format: "yyyyMM")
        let results = realm.objects(IncomeConsumeModel.self).filter("incConsDate LIKE %@", "*\(str_yyyyMM)*")
        return results.isEmpty ? false : true
    }
    
    /** 当日の収入または支出の取引の有無を取得
     @param 日付(Date型)
     @param 収入・支出フラグ
     @return 日毎の収入または支出の有無
     */
    func isExsistIncConsData(day: Date, houseHoldType: Int) -> Bool {
        let dateStr = getStringDate(date: day, format: dateFormatter)
        let results = realm.objects(IncomeConsumeModel.self).where({$0.houseHoldType == houseHoldType && $0.incConsDate == dateStr})
        return results.isEmpty ? false : true
    }
    
    /* チャート表示用の月間収入・支出情報を取得 収支項目ごとのカラーインデックスと金額を取得
     @param houseHoldType 家計タイプ
     @param selectDate 選択日
     @return Dicionary[収支項目主キー : 項目ごとの金額合計]
     */
    func getMonthIncConsDataForChart(houseHoldType: Int, selectDate: Date) -> [String: Int] {
        var dicForChart = [String : Int]()
        
        let str_yyyyMM = getStringDate(date: selectDate, format: "yyyyMM")
        let results = realm.objects(IncomeConsumeModel.self)
            .where({$0.houseHoldType == houseHoldType})
            .filter("incConsDate LIKE %@", "*\(str_yyyyMM)*")
        
        results.forEach { result in
            let incConsSecKey = result.incConsSecKey
            if dicForChart[incConsSecKey] != nil {
                dicForChart[incConsSecKey]! += result.incConsAmtValue
            } else {
                dicForChart[incConsSecKey] = result.incConsAmtValue
            }
        }
        return dicForChart
    }
    
    /* チャート表示用の年間収入・支出情報を取得 収支項目ごとのカラーインデックスと金額を取得
     @param houseHoldType 家計タイプ
     @param year 該当年
     @return Dicionary[収支項目主キー : 項目ごとの金額合計]
     */
    func getYearIncConsDataForChart(houseHoldType: Int, year: Int) -> [String: Int] {
        var dicForChart = [String : Int]()
        let str_yyyy = String(year)
        // 年間の家計別項目主キーを取得(項目主キーの重複はなし)
        let distSecKeyResults = realm.objects(IncomeConsumeModel.self)
            .where({$0.houseHoldType == houseHoldType})
            .filter("incConsDate LIKE %@", "*\(str_yyyy)*")
            .distinct(by: ["incConsSecKey"])
        
        // 項目ごと取得する
        distSecKeyResults.forEach { result in
            let incConsSecKey = result.incConsSecKey
            let amtTotalBySecKey: Int = realm.objects(IncomeConsumeModel.self)
                .filter("incConsDate LIKE %@", "*\(str_yyyy)*")
                .where({$0.incConsSecKey == incConsSecKey})
                .sum(ofProperty: "incConsAmtValue")
            dicForChart[incConsSecKey] = amtTotalBySecKey
        }
        return dicForChart
    }
    
    /* 項目別の収支合計を取得する（最新を取得する）
     @param getSize: 取得数
     @param selectDate: 日付
     @return 表示用モデル
     */
    func getIncConsTotalBySec(getSize: Int, selectDate: Date) -> [IncConsMonTotalBySec]{
        let str_yyyyMM = getStringDate(date: selectDate, format: "yyyyMM")
        // 該当月の最新の収支結果を取得する
        let resultsByMon = realm.objects(IncomeConsumeModel.self).filter("incConsDate LIKE %@", "*\(str_yyyyMM)*")
                                                           .sorted(byKeyPath: "incConsDate", ascending: false)
        // 返却用配列
        var amtTotalBySecArray: [IncConsMonTotalBySec] = []
        // 重複判定用項目主キー配列
        var secKeyArray: [String] = []
        resultsByMon.forEach { result in
            if !secKeyArray.contains(result.incConsSecKey) {
                secKeyArray.append(result.incConsSecKey)
                // 収支項目を取得
                let secObj = realm.object(ofType: IncConsSectionModel.self, forPrimaryKey: result.incConsSecKey) ?? IncConsSectionModel()
                // 項目別金額合計を取得
                let resultsBySecMon = resultsByMon.where({$0.incConsSecKey == result.incConsSecKey})
                let total: Int = resultsBySecMon.sum(ofProperty: "incConsAmtValue")
                // 表示用モデルの格納
                let viewModel = IncConsMonTotalBySec(incConsSecObj: secObj, amtTotalBySecMon: total)
                amtTotalBySecArray.append(viewModel)
            }
            // 取得サイズを超える場合は、ループを抜ける
            if secKeyArray.count == getSize {
                return
            }
        }
        return amtTotalBySecArray
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
    func getYearIncConsChartEntry(year: Int) -> [IncConsChartEntry] {
        let thisDecember = calendarService.getSettingDate(year: year + 1, month: 1)
        // 返却用チャート配列
        var chartEntries: [IncConsChartEntry] = []
        // dateから一年前を取得する
        let aYearAgo = calendarService.xAfterMonth(date: thisDecember, value: -12)
        var months: [Date] = [aYearAgo]
        while months.count <= 12 {
            months.append(calendarService.nextMonth(date: months.last!))
        }
        months.forEach { date in
            let incTotalPerMonth = getMonthIncOrConsAmtTotal(date: date, houseHoldType: 0)
            let consTotalPerMonth = getMonthIncOrConsAmtTotal(date: date, houseHoldType: 1)
            let totalGap = incTotalPerMonth - consTotalPerMonth
            let monthStr = getStringDate(date: date, format: "M月")
            chartEntries.append(.init(type: "収入額", month: monthStr, amount: incTotalPerMonth, color: .blue))
            chartEntries.append(.init(type: "支出額", month: monthStr, amount: consTotalPerMonth, color: .red))
            chartEntries.append(.init(type: "収支合計", month: monthStr, amount: totalGap, color: .changeableText))
        }
        return chartEntries
    }
    
    func getMonthIncConsChartEntry(selectDate: Date) -> [IncConsChartEntry] {
        // 返却用チャート配列
        var chartEntries: [IncConsChartEntry] = []
        // dateから一年前を取得する
//        let aYearAgo = calendarService.xAfterMonth(date: selectDate, value: -makeSize)
//        var months: [Date] = [aYearAgo]
//        while months.count <= makeSize {
//            months.append(calendarService.nextMonth(date: months.last!))
//        }
//        months.forEach { date in
        let incTotalPerMonth = getMonthIncOrConsAmtTotal(date: selectDate, houseHoldType: 0)
        let consTotalPerMonth = getMonthIncOrConsAmtTotal(date: selectDate, houseHoldType: 1)
        let totalGap = incTotalPerMonth - consTotalPerMonth
        let monthStr = getStringDate(date: selectDate, format: "yyyy年M月")
        chartEntries.append(.init(type: "収入額", month: monthStr, amount: incTotalPerMonth, color: .blue))
        chartEntries.append(.init(type: "支出額", month: monthStr, amount: consTotalPerMonth, color: .red))
        chartEntries.append(.init(type: "収支合計", month: monthStr, amount: totalGap, color: .changeableText))
//        }
        return chartEntries
    }
    
    /** 家計タイプによって金額記号を取得する
     @param 収入・支出情報
     @return 金額記号
     */
    func getAmountSymbol(result: IncomeConsumeModel) -> String {
        var symbol = ""
        if result.houseHoldType == 2 {
            if result.incConsAmtValue == 0 {
                symbol = "±"
            } else if result.incConsAmtValue > 0 {
                symbol = "+"
            }
        } else {
            symbol = "¥"
        }
        return symbol
    }
    
    /** 日毎の収入・支出の表示を切り替えるフラグ配列の取得
     @param 選択された日付
     @return 表示フラグ配列
     */
    func getIncConsDispFlgs(selectDate: Date, listType: Int) -> [Bool] {
        var flgs = [Bool]()
        let datas = getIncConsPerDate(selectDate: selectDate, listType: listType)
        datas.forEach { data in
            flgs.append(true)
        }
        return flgs
    }
    
    /** 年間収支表示・非表示フラグ配列を作成
     @return 表示フラグ配列
     */
    func getMonthTotalDispFlg() -> [Bool] {
        var flgs = [Bool]()
        for _ in 1 ... 12 {
            flgs.append(true)
        }
        return flgs
    }
    
    /* 収支変更用　連携された残高を取得する
     @param 収支情報オブジェクト
     @return 連携残高配列
     */
    func getLinkBalKeyArray(incConsObj: IncomeConsumeModel) -> [String] {
        var array: [String] = []
        incConsObj.balLinkAmtList.forEach { obj in
            array.append(obj.balanceKey)
        }
        return array
    }
    
    /* 収支変更用　表示用残高連携収支情報を取得する
     @param 収支情報オブジェクト
     @return 表示用残高連携収支情報配列
     */
    func getLinkBalAmtArrayForView(incConsObj: IncomeConsumeModel) -> [IncConsBalLinkAmtModelForView] {
        var array: [IncConsBalLinkAmtModelForView] = []
        incConsObj.balLinkAmtList.forEach { obj in
            let linkBalAmtForView = IncConsBalLinkAmtModelForView(balanceKey: obj.balanceKey,
                                                                  incConsAmt: obj.incConsAmt,
                                                                  isIncreaseBal: obj.isIncreaseBal)
            array.append(linkBalAmtForView)
        }
        return array
    }
    
    /** 項目別支出合計学を取得する
     @param 日付
     @return 項目・金額辞書
     */
    func getConsTotalBySec(date: Date) -> [String: Int] {
        var dic: [String: Int] = [:]
        // 支出項目を全件取得
        let consSecResults = realm.objects(IncConsSectionModel.self).where({$0.houseHoldType == 1})
        // 該当月の支出情報を取得
        let str_yyyyMM = getStringDate(date: date, format: "yyyyMM")
        let consResults = realm.objects(IncomeConsumeModel.self).where({$0.houseHoldType == 1})
                                                                .filter("incConsDate LIKE %@", "*\(str_yyyyMM)*")
        consSecResults.forEach { consSecResult in
            let secKey = consSecResult.incConsSecKey
            // 該当月の支出情報から一致する項目の合計金額を取得する
            let consTotalBySec: Int = consResults.where({$0.incConsSecKey == secKey}).sum(ofProperty: "incConsAmtValue") ?? 0
            // 支出項目の主キーと支出合計金額を保持
            dic[secKey] = consTotalBySec
        }
        return dic
    }
}

