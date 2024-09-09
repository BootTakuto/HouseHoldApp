//
//  ViewModelService.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/08/15.
//

import Foundation
import SwiftUI

struct ViewModelService {
    /** 一部分の属性を変更したテキストを取得
     @param text テキスト
     @param targetText 対象となるテキスト
     @param color 色
     @param fontWeight フォントの太さ
     @return 属性変更後のテキスト
     */
    static func getAttributedText(text: String,
                           targetText: String,
                           fontWeight: Font.Weight) -> AttributedString {
        var attributedString = AttributedString(text)
        if let range = attributedString.range(of: targetText) {
            attributedString[range].font = .system(.body, weight: fontWeight)
        }
        return attributedString
    }
}
