//
//  Charts.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/04/25.
//

import SwiftUI
import Charts
import RealmSwift

class FinanceCharts {
    // service
    let balService = BalanceService()
    let incConsService = IncomeConsumeService()
    @State var balResults = BalanceService().getBalanceResults()
    @ObservedResults(IncomeConsumeModel.self) var incResults
    @ObservedResults(IncomeConsumeModel.self) var consResults
    // 残高棒グラフ
    @ViewBuilder
    func BalCompareChart() -> some View {
        Chart {
            ForEach(Array(balResults.sorted(by: {$0.balanceAmt > $1.balanceAmt})), id: \.self) { result in
                BarMark(
                    x: .value("label", result.balanceNm),
                    y: .value("amount", result.balanceAmt)
                ).foregroundStyle(ColorAndImage.colors[result.colorIndex])
                    .annotation {
                        Text("¥\(result.balanceAmt)")
                            .font(.caption2)
                            .fontWeight(.light)
                            .foregroundStyle(Color.changeableText)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
            }
        }
    }
    
    @ViewBuilder
    func IncConsCompareChart(selectDate: Date, makeSize: Int) -> some View {
        let chartEntries = incConsService.getIncConsChartEntry(selectDate: selectDate, makeSize: makeSize)
        let selectMonth = incConsService.getStringDate(date: selectDate, format: "yy年M月")
        Chart {
            ForEach(chartEntries) { data in
                if data.type == "収支合計" {
                    if makeSize > 0 {
                        LineMark(x: .value("month", data.month),
                                 y: .value("totalAmt", data.amount)
                        ).lineStyle(StrokeStyle(lineWidth: 0.5))
                            .foregroundStyle(data.color)
                        PointMark(x: .value("month", data.month),
                                  y: .value("totalAmt", data.amount)
                        ).foregroundStyle(data.color)
                            .annotation(position: .bottom, alignment: .bottomLeading) {
                                Text("¥\(data.amount)")
                                    .font(.caption2)
                                    .fontWeight(.light)
                            }
                    }
                } else {
                    BarMark(
                        x: .value("month", data.month),
                        y: .value("amount", data.amount)
                    ).foregroundStyle(selectMonth == data.month ? data.color : data.color.opacity(0.5))
                        .position(by: .value("type", data.type))
                        .annotation(position: .top) {
                            if makeSize == 0 {
                                Text("¥\(data.amount)")
                                    .font(.caption2)
                                    .fontWeight(.light)
                                    .foregroundStyle(Color.changeableText)
                                    .frame(width: 50)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }
                        }
                }
            }
        }.padding(.top, 5)
    }
    
    @ViewBuilder
    func IncConsRateChart(houseHoldType: Int, date: Date) -> some View {
        let incFlg = houseHoldType == 0 ? true : false
        let secAmtDic = incConsService.getIncConsDataForChart(houseHoldType: houseHoldType, selectDate: date)
        let totalAmt: Int = incConsService.getIncOrConsAmtTotal(date: date, houseHoldType: houseHoldType)
        ZStack {
            Chart {
                ForEach(secAmtDic.sorted(by: >), id: \.key) { key, value in
                    let colorIndex = self.incConsService.getColorIndex(incConsSecKey: key)
                    let color = ColorAndImage.colors[colorIndex]
                    SectorMark(
                        angle: .value("count", totalAmt == 0 ? 1 : value),
                        innerRadius: .inset(30),
                        angularInset: 0.5
                    ).foregroundStyle(totalAmt != 0 ? color : incFlg ? .blue.opacity(0.25) : .red.opacity(0.25))
//                        .annotation(position: .overlay) {
//                            Text("¥\(value)")
//                                .font(.system(.caption2, design: .rounded))
//                                .foregroundStyle(Color.changeableText)
//                                .lineLimit(1)
//                                .minimumScaleFactor(0.5)
//                        }
                }
            }
            VStack {
                Text(incFlg ? "収入総額" : "支出総額")
                    .font(.caption2)
                    .foregroundStyle(Color.changeableText)
                Text("¥\(totalAmt)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(incFlg ? Color.blue : Color.red)
            }
        }
    }
}

struct IncConsChartEntry: Identifiable {
    // 収入または支出(income: 収入, consume: 支出)
    var type: String
    // 収入・支出月
    var month: String
    // 月別収入・支出合計金額
    var amount: Int
    // カラー
    var color: Color
    // 一意性(202402income)
    var id: String {
        return month + type
    }
}

#Preview {
    ContentView()
}

//#Preview {
//    @State var isPresentedFlg = false
//    @State var chartIndex = 0
//    return IncConsSummaryView(accentColors: [.purple, .indigo],
//                              isPresentedFlg: $isPresentedFlg, chartIndex: 0)
//}
