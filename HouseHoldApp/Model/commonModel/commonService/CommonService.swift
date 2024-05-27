//
//  CommonService.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/08.
//

import Foundation
import RealmSwift
import SwiftUI

class CommonService {
    let UD_ACCENT_COLORS_INDEX = "ACCENT_COLORS_INDEX"
    
    /* ▼マイグレーションを兼ねたrealmの生成　*/
    let realm: Realm = {
//        let newSchemaVersion: UInt64 = 0
        // schemaVersion
//        if Realm.Configuration.defaultConfiguration.schemaVersion < newSchemaVersion {
//            let config = Realm.Configuration(
        // schemaVersionを上げる
//            schemaVersion: newSchemaVersion,
        // データの置き換えなど必要な処理
//            migrationBlock: { migration, oldSchemaVersion in
//                if oldSchemaVersion < newSchemaVersion {
//                    // 必要ならデータの置き換えなどを行う
//                }
//            })
//            Realm.Configuration.defaultConfiguration = config
//        }
        let realm = try! Realm()
        return realm
    }()
    
    /**  Date型をString型に変換
     @param Date
     @param フォーマット
     @return Stringに変換した日付を返却
     */
    func getStringDate(date: Date, format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
    
    /**  String型をDate型に変換
     @param DateString
     @param フォーマット
     @return String → Dateに変換しDateを返却
     */
    func convertStrToDate(dateStr: String, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        return dateFormatter.date(from: dateStr) ?? Date()
    }
    
    /** 任意の場所に文字列を挿入する
     @param 加工したいターゲットとなる文字列
     @param 挿入する文字列
     @param 文字列の何番目か
     @return 加工された文字を返却
     */
    func insertText(targetText: String, insertText: String, prefix: Int) -> String {
        let text = targetText
        return String(text.prefix(prefix)) + insertText + String(text.suffix(text.count - prefix))
    }
}
