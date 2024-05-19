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
    @ObservedResults(BalanceModel.self) var assetsResults
    @ObservedResults(BalanceModel.self) var debtResults
    @ObservedResults(IncomeConsumeModel.self) var incResults
    @ObservedResults(IncomeConsumeModel.self) var consResults
    // ▼資産と負債　純資産チャート
    @ViewBuilder
    func BalCompareChart() -> some View {
        let assetsBalTotal = balService.getBalanceTotal()
        let debtBalTotal = balService.getBalanceTotal()
        let netWorth = assetsBalTotal - debtBalTotal
        Chart {
            BarMark(
                x: .value("fruit", "資産"),
                y: .value("Price", assetsBalTotal)
            ).foregroundStyle(Color.blue)
            BarMark(
                x: .value("fruit", "負債"),
                y: .value("Price", debtBalTotal)
            ).foregroundStyle(Color.red)
            BarMark(
                x: .value("fruit", "純資産"),
                y: .value("Price", netWorth)
            ).foregroundStyle(netWorth > 0 ? Color.blue : Color.red)
        }
    }
    
    // ▼資産or負債の割合
    @ViewBuilder
    func BalRateChart(assetsFlg: Bool) -> some View {
        ZStack {
            Chart {
                ForEach(assetsFlg ? assetsResults.indices : debtResults.indices, id: \.self) {index in
                    let balAmt = self.assetsResults[index].balanceAmt
                    SectorMark(
                        angle: .value("count", balAmt),
                        innerRadius: .inset(30),
                        angularInset: 1
                    )
                    .foregroundStyle(assetsFlg ? Color.blue : Color.red)
                    .annotation(position: .overlay) {
                        Text("¥\(balAmt)")
                            .font(.system(.caption2, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                }
            }
            VStack {
                Text(assetsFlg ? "資産総額" : "負債総額")
                    .font(.caption2)
                    .foregroundStyle(Color.changeableText)
                Text("¥\(balService.getBalanceTotal())")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(assetsFlg ? Color.blue : Color.red)
            }
        }
    }
    
    @ViewBuilder
    func IncConsCompareChart(selectDate: Date, makeSize: Int) -> some View {
        let chartEntries = incConsService.getIncConsChartEntry(selectDate: selectDate, makeSize: makeSize)
        let selectMonth = incConsService.getStringDate(date: selectDate, format: "yy年M月")
        Chart {
            ForEach(chartEntries) { data in
                if data.type != "収支合計" {
                    BarMark(
                        x: .value("month", data.month),
                        y: .value("amount", data.amount)
                    ).foregroundStyle(selectMonth == data.month ? data.color : data.color.opacity(0.5))
                        .position(by: .value("type", data.type))
                } else {
                    LineMark(x: .value("month", data.month),
                             y: .value("totalAmt", data.amount)
                    ).lineStyle(StrokeStyle(lineWidth: 0.5))
                        .foregroundStyle(data.color)
                    PointMark(x: .value("month", data.month),
                              y: .value("totalAmt", data.amount)
                    ).foregroundStyle(data.color)
                }
            }
        }.chartForegroundStyleScale(["収入": .blue, "支出": .red, "収支合計": .changeableText])
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
                    SectorMark(
                        angle: .value("count", value),
                        innerRadius: .inset(30),
                        angularInset: 1
                    ).foregroundStyle(ColorAndImage.colors[colorIndex])
                        .annotation(position: .overlay) {
                            Text("¥\(value)")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(Color.changeableText)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }
                }
            }
            VStack {
                Text(incFlg ? "資産総額" : "負債総額")
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
    WholeSummary(accentColors: [.purple, .indigo])
}
