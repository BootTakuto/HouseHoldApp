//
//  MigrationSample.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/05/25.
//

import Foundation
import RealmSwift


class MigrationSample {
    /* ▼マイグレーションを兼ねたrealmの生成　*/
    let realm: Realm = {
        let newSchemaVersion: UInt64 = 0
        // ▼schemaversionがすでに更新されている場合マイグレを実施しない
        if Realm.Configuration.defaultConfiguration.schemaVersion < newSchemaVersion {
            // ①マイグレーションを実施　schemaversionなどを更新する
            let config = Realm.Configuration(
            schemaVersion: newSchemaVersion, // schemaVersionを0から1に増加。
            migrationBlock: { migration, oldSchemaVersion in
                // 設定前のschemaVersionが２より小さい場合、マイグレーションを実行。
                if oldSchemaVersion < newSchemaVersion {
//                    migration.enumerateObjects(ofType: IncomeConsumeModel.className()) { old, new in
//                        var balLinkList: [IncConsBalLinkAmtModel] = []
//                        var balLinkAmtModel = IncConsBalLinkAmtModel()
//                        let oldBalKeyList = old!["balanceKeyList"] as! RealmSwift.List<Swift.String>
//                        let oldAmtList = old!["incConsAmtList"] as! RealmSwift.List<Swift.Int>
//                        oldBalKeyList.indices.forEach { index in
//                            balLinkAmtModel.balanceKey = oldBalKeyList[index]
//                            balLinkAmtModel.incConsAmt = String(oldAmtList[index])
//                            balLinkList.append(balLinkAmtModel)
//                        }
//                        new!["balLinkAmtList"] = balLinkList
//                    }
                }
            })
            // ②マイグレーションを代入　defaultに設定
            Realm.Configuration.defaultConfiguration = config
        }
        // ③realmインスタンス生成と同時に①②が実行される
        let realm = try! Realm()
        return realm
    }()
}
