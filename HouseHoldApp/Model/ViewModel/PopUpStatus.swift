//
//  PopUpStatus.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/05/12.
//

import Foundation
enum PopUpStatus {
    case success            // 成功
    case failed             // 成功失敗
    case addBalance         // 残高登録
    case editBalance        // 残高変更
    case deleteBalance      // 残高削除
    case selectAccentColor  // テーマカラー選択
    case addIncConsSec      // 収入・支出項目の登録
    case editIncConsSec     // 収入・支出項目の編集
    case deleteIncConsSec   // 収入・支出項目の削除
    case addincConsCatg     // 収入・支出カテゴリーの登録
    case editIncConsCatg    // 収入・支出カテゴリーの編集
    case deleteIncConsCatg  // 収入・支出カテゴリーの削除
}
