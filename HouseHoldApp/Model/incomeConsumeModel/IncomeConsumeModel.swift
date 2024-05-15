//
//  IncomeConsumeModel.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/01/02.
//

import Foundation
import RealmSwift

/**
▼ 収入・支出情報
 ＊①残高ごとの金額の増減を管理したいため、balanceKeyを格納
 　→2024.03.22変更　一回の取引で複数の残高から入力されることも想定されるため(合算など)
 ＊②カテゴリー名・とそれを格納する項目(section)の主キーも格納しているため「IncConsSec」情報は不要
 ＊③date型は汎用性に欠けるため年月日をStringで格納　→ 月、週ごとの合計などを取得したとしてもStringのFor文で回し、取得しやすい
 ＊④②では収支項目削除した際に削除された項目を検知できないため、「IncConsSecKey」を追加
 ＊⑤2024.03.22追加　一回の取引で複数の残高入力を想定し、listで格納
 */

class IncomeConsumeModel: Object, Identifiable {
    // 収入・支出情報主キー
    @Persisted(primaryKey: true) var incConsKey = ""
    // 収入フラグ(0：収入, 1：支出, 2：その他)
    @Persisted var houseHoldType = 0
    // 収入・支出カテゴリー主キー　＊④
    @Persisted var incConsSecKey = ""
    // 収入・支出カテゴリー主キー　＊②
    @Persisted var incConsCatgKey = ""
    // 残高キー (incConsAmtListのindexと等しい)　＊①
    @Persisted var balanceKeyList = RealmSwift.List<String>()
    // 金額のlist (balanceKeyListのindexと等しい)　＊⑤
    @Persisted var incConsAmtList = RealmSwift.List<Int>()
    // 金額
    @Persisted var incConsAmtValue = 0
    // 日付　＊③
    @Persisted var incConsDate = ""
    // メモ
    @Persisted var memo = ""
}
