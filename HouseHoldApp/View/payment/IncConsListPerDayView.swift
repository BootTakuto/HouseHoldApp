//
//  IncConsListView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/04/22.
//

import SwiftUI
import RealmSwift

struct IncConsListPerDayView: View {
    @Binding var perDayListFlg: Bool
    @Binding var selectDay: Date
    // 遷移画面
    @State var detailPageFlg = false
    // service
    let incConsService = IncomeConsumeService()
    // 汎用ビュー
    let generalView = GeneralComponentView()
    func incConsResults() -> Results<IncomeConsumeModel> {
        let dateStr = incConsService.getStringDate(date: selectDay, format: "yyyyMMdd")
        @ObservedResults(IncomeConsumeModel.self, where: {$0.incConsDate == dateStr}) var results
        return results
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView {
                    VStack {
                        let results = incConsResults()
                        ForEach(results.indices, id: \.self) { index in
                            let result = results[index]
                            DetailCard(proxy: proxy, result: result)
                                .frame(height: 100)
                                .padding(.horizontal, 20)
                        }
                    }
                }
            }.navigationDestination(isPresented: $detailPageFlg) {
            }
        }
    }
    
    @ViewBuilder
    func DetailCard(proxy: GeometryProxy, result: IncomeConsumeModel) -> some View {
        let secResult = try? Realm().object(ofType: IncConsSectionModel.self, forPrimaryKey: result.incConsSecKey)
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
            VStack(alignment: .trailing) {
                HStack {
                    Group {
                        if let unwrapSecResult = secResult {
                            let catgResult = try! Realm().object(ofType: IncConsCategoryModel.self,
                                                                 forPrimaryKey: result.incConsCatgKey)!
                            let color = ColorAndImage.colors[unwrapSecResult.incConsSecColorIndex]
                            let image = unwrapSecResult.incConsSecImage
                            let text = catgResult.incConsCatgNm
                            generalView.RoundedIcon(radius: 5, color: color, image: image, text: text)
                                .frame(width: 40, height: 40)
                            Text(catgResult.incConsCatgNm)
                                .font(.system(.caption, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.changeableText)
                        } else {
                            let color = ColorAndImage.colors[24]
                            generalView.RoundedIcon(radius: 5, color: color, image: "exclamationmark",
                                                    text: "未登録")
                            .frame(width: 40, height: 40)
                        }
                    }
                    Spacer()
                    Menu {
                        Button(action: {
                            //
                        }) {
                            HStack {
                                Text("詳細")
                                Image(systemName: "chevron.right")
                            }
                        }
                        Button(role: .destructive,action: {
                            //
                        }) {
                            HStack {
                                Text("削除")
                                Image(systemName: "trash")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.changeableText)
                            .rotationEffect(Angle(degrees: 90))
                            .padding(3)
                    }
                }
                Text("¥\(result.incConsAmtValue)")
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(result.incConsAmtValue == 0 ? .gray : result.houseHoldType == 0 ? .blue : .red)
            }.padding(.horizontal, 20)
        }
    }
}

#Preview {
    @State var perDayListFlg = true
    @State var selectDay = IncomeConsumeService().convertStrToDate(dateStr: "20240420", format: "yyyyMMdd")
    return IncConsListPerDayView(perDayListFlg: $perDayListFlg,
                                  selectDay: $selectDay)
}
