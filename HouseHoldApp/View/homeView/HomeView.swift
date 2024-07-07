//
//  WholeSummary.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2023/08/31.
//

import SwiftUI
import Charts

struct HomeView: View {
    var accentColors: [Color]
    @Binding var popUpFlg: Bool
    @Binding var popUpStatus: PopUpStatus
    @Environment(\.colorScheme) var colorScheme
    @State private var selectChart = 0
    @State private var selectDate = Date()
    @State private var chartIndex = 0
    // 画面操作
    @State var dispFlg = [true, true, true, true]
    @State var assetsChartDestFlg = false
    @State var incConsChartDestFlg = false
    /** 残高 */
    @State var balResults = BalanceService().getBalanceResults()
    // 項目アイコン　項目別月間収支合計
    let amtTotalBySecMon = IncomeConsumeService().getIncConsTotalBySec(getSize: 6, selectDate: Date())
    // charts
    let financeCharts = FinanceCharts()
    // 汎用ビュー
    let generalView = GeneralComponentView()
    // service
    let calendarService = CalendarService()
    let balanceService = BalanceService()
    let incConsCatgService = IncConSecCatgService()
    let incConsService = IncomeConsumeService()
    // 遷移情報
    @State var chartPageFlg = false
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 30) {
                            let height = (size.width / 2) - 40
                            HStack(spacing: 0) {
                                IncConsTodayCard(height: height)
                                    .frame(height: abs(height))
                                    .padding(.trailing, 10)
                                BudgetCard(height: height)
                                    .frame(height: abs(height))
                                    .padding(.leading, 10)
                            }
                            IncConsCard()
                                .frame(height: 350)
                            BalnceCard()
                                .frame(height: 300)
//                            BalanceChartArea(size: size)
//                                .padding(.bottom, 10)
//                            BudgetArea(size: size)
//                                .padding(.bottom, 10)
//                            IncConsChartArea(size: size)
//                                .padding(.bottom, 100)
                        }.padding(.top, 10)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                    }.scrollIndicators(.hidden)
                }
            }.navigationDestination(isPresented: $assetsChartDestFlg) {
                    
            }.navigationDestination(isPresented: $incConsChartDestFlg) {
                IncConsSummaryView(accentColors: accentColors,
                                   isPresentedFlg: $incConsChartDestFlg,
                                   chartIndex: chartIndex)
            }
        }
    }
    
    @ViewBuilder
    func IncConsTodayCard(height: CGFloat) -> some View {
        let dispCount = 2
        GeometryReader {
            let size = $0.size
            ZStack {
                generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                    .shadow(color: colorScheme == .dark ? .clear : .changeableShadow, radius: 5)
                VStack(spacing: 0) {
                    HStack {
                        let day = calendarService.getOnlyComponent(date: selectDate, component: .day)
                        let dayOfWeek = calendarService.getOnlyComponent(date: selectDate, component: .weekday)
                        let dayOfWeekSymbol = calendarService.getDayOfWeekSymbol(dayOfWeek: dayOfWeek)
                        Text("\(day)")
                            .font(.largeTitle)
                            .padding(.leading, 10)
                        generalView.Bar()
                            .frame(height: 20)
                        Text(dayOfWeekSymbol)
                        Spacer()
                    }.foregroundStyle(Color.changeableText)
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(0 ..< dispCount, id: \.self) {houseHoldType in
                                let isExsist = incConsService.isExsistIncConsData(day: selectDate,
                                                                                  houseHoldType: houseHoldType)
                                let amt = incConsService.getIncConsTotalPerDay(day: selectDate,
                                                                               houseHoldType: houseHoldType)
                                let type = houseHoldType == 0 ? "収入" : "支出"
                                VStack(alignment: .leading) {
                                    if isExsist {
                                        Text(type)
                                            .font(.caption)
                                        Text("¥\(amt)")
                                            .foregroundStyle(amt > 0 ? .blue : amt == 0 ? .changeableText : .red)
                                    } else {
                                        Text("本日の" + type + "はありません。")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    }
                                }.frame(width: size.width)
                            }
                        }.scrollTargetLayout()
                            .frame(height: abs(height * (2 / 3) - 20))
                        PagingIndicator(activeTint: .changeableText,
                                        inActiveTint: .gray.opacity(0.5))
                        .frame(height: 10)
                    }.scrollTargetBehavior(.viewAligned)
                }
            }
        }
    }
    
    @ViewBuilder
    func BudgetCard(height: CGFloat) -> some View {
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                .shadow(color: colorScheme == .dark ? .clear : .changeableShadow, radius: 5)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("今月の予算")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }.padding(.top, 10)
                    .padding(.horizontal, 10)
                ZStack {
                    Circle()
                        .stroke(lineWidth: 15)
                        .fill(Color(uiColor: .systemGray6)
                            .shadow(.inner(color: Color(uiColor: .systemGray3), radius: 3))
                        )
                        .overlay {
                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(lineWidth: 8)
                                .fill(.linearGradient(colors: accentColors,
                                                      startPoint: .topLeading, endPoint: .bottomLeading))
                                .rotationEffect(.degrees(270))
                        }
                    VStack {
                        Text("残り")
                        Text("¥1000")
                    }.font(.caption)
                        .fontWeight(.medium)
                }.padding()
            }.foregroundStyle(Color.changeableText)
        }
    }
    
    @ViewBuilder
    func IncConsCard() -> some View {
        GeometryReader {
            let size = $0.size
            let iconsRowCount = (amtTotalBySecMon.count - 1) / 2 + 1
            ZStack {
                generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                    .shadow(color: colorScheme == .dark ? .clear : .changeableShadow, radius: 5)
                let isExistMonthData = incConsService.isExistIncConsMonth(refDate: selectDate)
                    VStack(spacing: 0) {
                        HStack {
                            let month = calendarService.getOnlyComponent(date: selectDate,
                                                                         component: .month)
                            Text("\(month)" + "月の収入・支出")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                        }.padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .foregroundStyle(Color.changeableText)
                        if isExistMonthData {
                            ScrollView(.horizontal) {
                                HStack(spacing: 0) {
                                    Group {
//                                        IncConsCompareChartArea(size: size)
                                        financeCharts.IncConsCompareChart(selectDate: selectDate, makeSize: 0)
                                        financeCharts.IncConsRateChart(houseHoldType: 0, date: Date())
                                        financeCharts.IncConsRateChart(houseHoldType: 1, date: Date())
                                    }.frame(width: iconsRowCount == 1 ? size.width - 60 : iconsRowCount == 2 ?
                                            size.width - 50 : size.width - 40
                                    ).padding(iconsRowCount == 1 ? 10 : iconsRowCount == 2 ? 5 : 0)
                                }.scrollTargetLayout()
                                PagingIndicator(activeTint: .changeableText,
                                                inActiveTint: .gray.opacity(0.5))
                                .frame(height: 8)
                                .padding(.vertical, 5)
                            }
//                            .frame(height: size.height * (5 / 10))
                                .padding(.horizontal, 20)
                                .scrollTargetBehavior(.viewAligned)
                                .scrollIndicators(.hidden)
                        } else {
                            Text("今月の収入・支出はありません。")
                                .foregroundStyle(.gray)
                                .font(.caption)
//                                .frame(height: size.height * (5 / 10))
                        }
                        Rectangle()
                            .fill(colorScheme == .dark ? Color(uiColor: .systemGray5) : .white)
                            .overlay {
                                IncConsIcons(size: size)
                            }.frame(height: 40 * CGFloat(iconsRowCount) + 10)
                }.clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }.onTapGesture {
            self.incConsChartDestFlg = true
        }
    }
    
    @ViewBuilder
    func IncConsIcons(size: CGSize) -> some View {
        HStack(spacing: 10) {
            ForEach(0 ..< 2, id: \.self) { col in
                VStack(spacing: 10) {
                    ForEach(0 ..< 3, id: \.self) { row in
                        let index = col + (row * 2)
                        if index < amtTotalBySecMon.count {
                            let viewModel = amtTotalBySecMon[index]
                            let secObj = viewModel.incConsSecObj
                            let color = ColorAndImage.colors[secObj.incConsSecColorIndex]
                            let imageNm = secObj.incConsSecImage
                            HStack {
                                generalView.RoundedIcon(radius: 5, color: color, image: imageNm, text: "")
                                    .frame(width: 30, height: 30)
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(secObj.incConsSecName)
                                    Text("¥\(viewModel.amtTotalBySecMon)")
                                        .font(.caption)
                                        .foregroundStyle(secObj.houseHoldType == 0 ? .blue : .red)
                                }.font(.caption)
                                    .foregroundStyle(Color.changeableText)
                            }.frame(width: size.width / 2 - 20, height: 30, alignment: .topLeading)
                        } else if amtTotalBySecMon.count % 2 == 1 {
                            Color.clear
                                .frame(width: size.width / 2 - 20, height: 30, alignment: .topLeading)
                        } else if amtTotalBySecMon.count == 0 && index < 2 {
                            HStack {
                                generalView.RoundedIcon(radius: 5, color: Color(uiColor: .systemGray3), image: "", text: "")
                                    .frame(width: 30, height: 30)
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("---")
                                    Text("---")
                                }.foregroundStyle(.gray)
                                    .font(.caption)
                            }.frame(width: size.width / 2 - 20, height: 30, alignment: .topLeading)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func IncConsCompareChartArea(size: CGSize) -> some View {
        VStack(spacing: 0) {
            financeCharts.IncConsCompareChart(selectDate: Date(), makeSize: 0)
            GeometryReader { geometry in
                HStack(spacing: 5) {
                    let incMonthTotal = incConsService.getIncOrConsAmtTotal(date: selectDate,
                                                                            houseHoldType: 0)
                    let consMonthTotal = incConsService.getIncOrConsAmtTotal(date: selectDate,
                                                                             houseHoldType: 1)
                    let gapMonthTotal = incMonthTotal - consMonthTotal
                    Group {
                        VStack(alignment: .leading) {
                            Text("収入")
                            Text("¥\(incMonthTotal)")
                                .foregroundStyle(Color.blue)
                        }
                        VStack(alignment: .leading) {
                            Text("支出")
                            Text("¥\(consMonthTotal)")
                                .foregroundStyle(Color.red)
                        }
                        VStack(alignment: .leading) {
                            Text("差額")
                            Text("¥\(gapMonthTotal)")
                                .foregroundStyle(gapMonthTotal > 0 ? Color.blue : Color.red)
                        }
                    }.frame(width: geometry.size.width / 3, alignment: .leading)
                }
            }.font(.caption)
            .frame(height: 30)
                .foregroundStyle(Color.changeableText)
                .padding(.top, 10)
                
        }
    }
    
    @ViewBuilder
    func BalnceCard() -> some View {
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                .shadow(color: colorScheme == .dark ? .clear : .changeableShadow, radius: 5)
            VStack(alignment: .leading, spacing: 0) {
                Text("残高")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.leading, 20)
                    .padding(.top, 10)
                financeCharts.BalCompareChart()
                    .padding()
            }.foregroundStyle(Color.changeableText)
        }
    }
    
    /** ▼残高チャート **/
    @ViewBuilder
    func miniBalIcon(balResult: BalanceModel) -> some View {
        HStack {
            Circle()
                .fill(ColorAndImage.colors[balResult.colorIndex])
                .frame(width: 15)
            VStack(alignment: .leading) {
                Text(balResult.balanceNm)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.changeableText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("¥\(balResult.balanceAmt)")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(balResult.balanceAmt > 0 ? .blue : .red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }.frame(maxWidth: 100, alignment: .leading)
        }.padding(3)
            .padding(.horizontal, 5)
            .background(colorScheme == .dark ? Color(uiColor: .systemGray5) : Color.changeable)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: colorScheme == .dark ? .clear : Color(uiColor: .systemGray4),
                    radius: colorScheme == .dark ? 0 : 5)
    }
    
    @ViewBuilder
    func BalanceChartArea(size: CGSize) -> some View {
        let balTotal = balanceService.getBalanceTotal()
        VStack {
            if self.dispFlg[0] {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array(balResults.sorted(by: {$0.balanceAmt > $1.balanceAmt})), id: \.self) { result in
                            miniBalIcon(balResult: result)
                        }
                    }.padding(.horizontal, 5)
                        .padding(.vertical, 8)
                }
                ZStack {
                    if colorScheme == .dark {
                        Color(uiColor: .systemGray5)
                            .opacity(0.6)
                    } else {
                        Color.white
                    }
                    VStack(spacing: 0) {
                        ZStack(alignment: .bottom) {
                            financeCharts.BalCompareChart()
                                .padding()
                                .frame(width: abs(size.width - 40), height: 200)
                            UIGlassCard(effect: .systemUltraThinMaterial)
                                .blur(radius: 10)
                                .frame(height: 250 / 5)
                            HStack {
                                Text("残高合計")
                                    .foregroundStyle(Color.changeableText)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("¥\(balTotal)")
                                    .fontWeight(.medium)
                                    .foregroundStyle(balTotal > 0 ? .blue : .red)
                                    .frame(width: abs((size.width - 60) / 2), alignment: .trailing)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }.padding(.horizontal, 20)
                                .padding(.bottom, 10)
                        }
                        ZStack {
                            if colorScheme == .dark {
                                Color(uiColor: .systemGray5)
                            } else {
                                Color.white
                            }
                            HStack {
                                Text("詳細へ")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }.padding(.horizontal, 20)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.changeableText)
                        }.frame(height: 50)
                    }.frame(height: 250)
                }.clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: colorScheme == .dark ? .clear : Color(uiColor: .systemGray4), radius: 5)
            }
        }.padding(.vertical, 10)
            .padding(.horizontal, 20)
    }
    
    /** ▼収支チャート **/
    @ViewBuilder
    func ChartCard(size: CGSize, index: Int) -> some View {
        let incConsChartTitles = ["収入・支出比較", "収入の構成", "支出の構成"]
        let incConsChartsExplains = ["収入と支出を比較し\n今月の収支合計を確認できます",
                                     "収入の構成割合を確認できます\n",
                                     "支出の構成割合を確認できます\n"]
        ZStack {
            if colorScheme == .dark {
                Color(uiColor: .systemGray5)
                    .opacity(0.6)
            } else {
                Color.white
            }
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    switch index {
                    case 0:
                        financeCharts.IncConsCompareChart(selectDate: Date(), makeSize: 2).padding()
                    case 1:
                        financeCharts.IncConsRateChart(houseHoldType: 0, date: Date()).padding()
                    case 2:
                        financeCharts.IncConsRateChart(houseHoldType: 1, date: Date()).padding()
                    default:
                        financeCharts.IncConsCompareChart(selectDate: Date(), makeSize: 2).padding()
                    }
                    UIGlassCard(effect: .systemUltraThinMaterial)
                        .blur(radius: 8)
                        .frame(height: 250 / 4)
                    VStack(alignment: .leading) {
                        Text(incConsChartTitles[index])
                        Text(incConsChartsExplains[index])
                            .font(.caption)
                    }.padding(.bottom, 5)
                        .frame(maxWidth: 300 - 50, alignment: .leading)
                        .foregroundStyle(Color.changeableText)
                }
                ZStack {
                    if colorScheme == .dark {
                        Color(uiColor: .systemGray5)
                    } else {
                        Color.white
                    }
                    HStack {
                        Text("詳細へ")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }.padding(.horizontal, 20)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.changeableText)
                }.frame(height: 40)
            }
        }.clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(width: abs(size.width - 100), height: 250)
            .padding(.horizontal, 10)
            .compositingGroup()
            .shadow(color: colorScheme == .dark ? .clear : Color(uiColor: .systemGray4), radius: 5)
    }
    
    @ViewBuilder
    func incConsBalMiniIcon(isKindFlg: Int, label: String, amt: Int) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.changeableText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("¥\(amt)")
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(isKindFlg == 1 || amt <= 0 ? .red :  .blue)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }.frame(width: 100, alignment: .leading)
        }.padding(3)
            .padding(.horizontal, 5)
            .background(colorScheme == .dark ? Color(uiColor: .systemGray5) : Color.changeable)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(color: colorScheme == .dark ? .clear : Color(uiColor: .systemGray4),
                    radius: colorScheme == .dark ? 0 : 5)
    }
    
    @ViewBuilder
    func IncConsChartArea(size: CGSize) -> some View {
        VStack {
            if self.dispFlg[3] {
                ScrollView(.horizontal) {
                    HStack(spacing: 0) {
                        ForEach (0 ..< 3, id: \.self) {index in
                            ChartCard(size: size, index: index)
                                .onTapGesture {
                                    self.chartIndex = index
                                    self.incConsChartDestFlg = true
                                }
                        }
                    }.padding(.vertical, 10)
                    .padding(.horizontal, 20)
                        .scrollTargetLayout()
                }.scrollTargetBehavior(.viewAligned)
                    .scrollIndicators(.hidden)
            }
        }.padding(.vertical, 10)
            .padding(.horizontal, 20)
    }
}



#Preview {
    ContentView()
}
