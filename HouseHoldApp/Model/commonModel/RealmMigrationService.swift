//
//  RealmMigrationService.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/17.
//

import Foundation
import RealmSwift

/** マイグレーションの変更に関わるデータの追加
 * 　条件①：プロパティの追加
 * 　条件②：プロパティ名の変更
 */
struct RealmMigrationService {
//    Realm.Configuration.defaultConfiguration = Realm.Configuration(
//            schemaVersion: 1,　// ①
//            migrationBlock: { migration, oldSchemaVersion in
//                if(oldSchemaVersion < 1) {
//                    migration.renameProperty(onType: Cat.className(), from: "name", to: "fullName") //②
//                }
//           }
//        })
    /** IncomeConsumeModelのプロパティ名の追加(incConsSecKey)に伴う、登録データへの追加
     @param --
     @return --
     */
//    func migIncomeConsumeModelincConsSecKey(realm: Realm) {
//        let results = realm.objects(IncomeConsumeModel.self)
//        results.forEach { result in
//            if !result.incConsCatgKey.isEmpty && result.incConsSecKey.isEmpty {
//                let incConsCatg = realm.object(ofType: IncConsCategoryModel.self, forPrimaryKey: result.incConsCatgKey)
//                let incConsSecKey = realm.object(ofType: IncConsSectionModel.self, forPrimaryKey: incConsCatg?.incConsSecKey)!.incConsSecKey
//                try! realm.write() {
//                    result.incConsSecKey = incConsSecKey
//                }
//            }
//        }
//    }
}
