//
//  CalendarService.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/10.
//

import Foundation
import SwiftUI

class CalendarService: CommonService {
    
    let calendar = Calendar(identifier: .gregorian)
    
    let current = Calendar.current
    
    /**
     @param 日付
     @return Date型　月初の日付
     */
    func getFirstDayOfMonth(date: Date) -> Date {
        let startDayOfMonth = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: startDayOfMonth)!
    }
    
    /**
     @param 日付
     @return Date型　月末の日付
     */
    func getEndDayOfMonth(date: Date) -> Date {
        let startDayOfMonth = getFirstDayOfMonth(date: date)
        let addDate = DateComponents(month: 1, day: -1)
        let endDayOfMonth = calendar.date(byAdding: addDate, to: startDayOfMonth)
        return endDayOfMonth!
    }
    
    /** 受け取ったdateから1年前を取得する
     @param 現在日付
     @return 前年
     */
    func previewYear(date: Date) -> Date {
        let calendar = Calendar.current
        let preYear = calendar.date(byAdding: .year, value: -1, to: date)!
        return preYear
    }
    
    /** 受け取ったdateから1年後を取得する
     @param 現在日付
     @return 翌年
     */
    func nextYear(date: Date) -> Date {
//        let calendar = Calendar.current
        let nextYear = current.date(byAdding: .year, value: 1, to: date)!
        return nextYear
    }
    
    /** 受け取ったdateから1ヶ月前を取得する
     @param 現在日付
     @return 前月
     */
    func previewMonth(date: Date) -> Date {
        let calendar = Calendar.current
        let preMonth = calendar.date(byAdding: .month, value: -1, to: date)!
        return preMonth
    }
    
    /** 受け取ったdateから1ヶ月後を取得する
     @param 現在日付
     @return 来月
     */
    func nextMonth(date: Date) -> Date {
        let calendar = Calendar.current
        let nextMonth = calendar.date(byAdding: .month, value: 1, to: date)!
        return nextMonth
    }
    
    /** 引数で受け取ったXヶ月後を取得する
     @param 現在日付
     @return xヶ月後の月
     */
    func xAfterMonth(date: Date, value: Int) -> Date {
        return current.date(byAdding: .month, value: value, to: date)!
    }
    
    /** 日付から年・月・日等のそれぞれのみを返す
     @param 日付
     @reutrn 月のみ
     */
    func getOnlyComponent(date: Date, component: Calendar.Component) -> Int {
        let component = current.component(component, from: date)
        return component
    }
    
    /** 異なる月であるかを判定する
        カレンダーで表示されている日付が別の月の日付かを判定するために使用
     @param 日付(Date)
     @return 異なる月か否か
     */
    func isDifferentMonth(selectDate: Date, calendarDate: Date) -> Bool {
        // ▼ 選択している日付の月
        let date = getStringDate(date: selectDate, format: "MM")
        // ▼ カレンダーで表示している月
        let calendarDate = getStringDate(date: calendarDate, format: "MM")
        return date != calendarDate
    }
    
    /** 土日の色を取得する
     @param 連番
     @param 列の連番
     @return 色
     */
    func getDayColor(index: Int, row: Int, selectDate: Date, calendarDate: Date) -> Color {
        var color: Color = .black
        let sevenMultiple = 7 * row
        if isDifferentMonth(selectDate: selectDate, calendarDate: calendarDate) {
            color = .gray
        } else {
            if sevenMultiple  == index {
                color = .red
            } else if sevenMultiple - 1 == index {
                color = .blue
            } else {
                color = .changeableText
            }
        }
        return color
    }
    
    /** 月初の曜日を基にカレンダー用の日付を取得する。
        先月を含めた最初の日付から42日進めて日付(Date型)配列を作成する。
     @param
     @param
     @reutrn
     */
    func getDatesOfMonth(date: Date) -> [Date] {
        // -1日0月1火2水3木4金5土
        let firstDay = getFirstDayOfMonth(date: date)
        let firstWeekDay = calendar.dateComponents([.weekday], from: firstDay).weekday! - 2
        let datesAmt = 42
        var dates = [Date]()
        if firstWeekDay == 0 {
            dates.append(firstDay)
        } else {
            let calendarFirstDay = calendar.date(byAdding: .day,
                                                 value: firstWeekDay == -1 ? -6 : -firstWeekDay,
                                                 to: firstDay)
            dates.append(calendarFirstDay!)
        }
        for i in 1 ..< datesAmt {
            let calendarFirstDay = dates[0]
            let day = calendar.date(byAdding: .day, value: i, to: calendarFirstDay)
            dates.append(day!)
        }
        return dates
    }
    
    /** 任意で年月を取得する
     @param 年、月
     @return 任意で作成された日付
     */
    func getSettingDate(year: Int, month: Int) -> Date {
        let date = calendar.date(from: DateComponents(year: year, month: month, day: 1))
        return date ?? Date()
    }
}

