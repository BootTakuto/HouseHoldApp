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
    
    /* ▼マイグレーションを兼ねたrealmの生成
     */
    let realm: Realm = {
        
        let schemaVersion: UInt64 = 1
        // ▼schemaversionがすでに更新されている場合マイグレを実施しない
        if Realm.Configuration.defaultConfiguration.schemaVersion < schemaVersion {
            // ①マイグレーションを実施　schemaversionなどを更新する
            let config = Realm.Configuration(
            schemaVersion: schemaVersion, // schemaVersionを0から1に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが２より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < schemaVersion {
                    // ▼サンプル
                    //                    migration.create(IncomeConsumeModel.className(), value: ["incConsSecKey": ""])
                }
            })
            // ②マイグレーションを代入　defaultに設定
            Realm.Configuration.defaultConfiguration = config
        }
        // ③realmインスタンス生成と同時に①②が実行される
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
