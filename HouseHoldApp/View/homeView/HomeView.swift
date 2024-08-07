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
    @State var budgetDestFlg = false
    /** 予算 */
    @State var budgetObj = BudgetService().getBudgetInfo(selectDate: Date())
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
    let budgetService = BudgetService()
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
                            BalnceCard(size: size)
                                .frame(height: 300)
                        }.padding(.top, 10)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                    }.scrollIndicators(.hidden)
                }
            }.navigationDestination(isPresented: $budgetDestFlg) {
                BudgetView(accentColors: accentColors, budgetDestFlg: $budgetDestFlg)
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
//                        let day = calendarService.getOnlyComponent(date: selectDate, component: .day)
                        let day = calendarService.getStringDate(date: selectDate, format: "M/d")
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
                                            .foregroundStyle(houseHoldType == 0 && amt > 0 ? .blue : amt == 0 ? .changeableText : .red)
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
        let budgetRate: Double = budgetService.getBudgetRate(selectDate: selectDate)
        let consTotal = incConsService.getMonthIncOrConsAmtTotal(date: selectDate, houseHoldType: 1)
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                .shadow(color: colorScheme == .dark ? .clear : .changeableShadow, radius: 5)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("今月の予算")
                        .font(.caption)
                        .fontWeight(.medium)
                    Spacer()
                    Image(systemName: "arrow.right")
                        .font(.caption)
                }.padding(.top, 10)
                    .padding(.horizontal, 10)
                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .fill(Color(uiColor: .systemGray6)
                            .shadow(.inner(color: Color(uiColor: .systemGray3), radius: 3))
                        )
                        .overlay {
                            Circle()
                                .trim(from: 0, to: budgetRate)
                                .stroke(lineWidth: 3)
                                .fill(.linearGradient(colors: accentColors,
                                                      startPoint: .topLeading, endPoint: .bottomLeading))
                                .rotationEffect(.degrees(270))
                        }
                    VStack {
                        if budgetObj != nil {
                            Text("予算残高")
                            Text("¥\(budgetObj!.budgetAmtTotal - consTotal)")
                        } else {
                            Text("未設定")
                                .foregroundStyle(.gray)
                        }
                    }.font(.caption)
//                        .fontWeight(.medium)
                }.padding()
            }.foregroundStyle(Color.changeableText)
        }.onTapGesture {
            self.budgetDestFlg = true
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
                            let month = calendarService.getOnlyComponent(date: selectDate, component: .month)
                            Text("\(month)" + "月の収入・支出")
                                .fontWeight(.medium)
                            Spacer()
                            Image(systemName: "arrow.right")
                                
                        }.font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .foregroundStyle(Color.changeableText)
                        if isExistMonthData {
                            ScrollView(.horizontal) {
                                HStack(spacing: 0) {
                                    Group {
                                        financeCharts.MonthIncConsCompareChart(selectDate: selectDate)
                                        financeCharts.MonthIncConsRateChart(houseHoldType: 0, date: Date())
                                        financeCharts.MonthIncConsRateChart(houseHoldType: 1, date: Date())
                                    }.frame(width: iconsRowCount == 1 ? abs(size.width - 60) : iconsRowCount == 2 ?
                                            abs(size.width - 50) : abs(size.width - 40)
                                    ).padding(iconsRowCount == 1 ? 10 : iconsRowCount == 2 ? 5 : 0)
                                }.scrollTargetLayout()
                                PagingIndicator(activeTint: .changeableText,
                                                inActiveTint: .gray.opacity(0.5))
                                .frame(height: 8)
                                .padding(.vertical, 5)
                            }.padding(.horizontal, 20)
                                .scrollTargetBehavior(.viewAligned)
                                .scrollIndicators(.hidden)
                        } else {
                            Text("今月の収入・支出はありません。")
                                .foregroundStyle(.gray)
                                .font(.caption)
                                .frame(height: size.height - 90)
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
                        let count = amtTotalBySecMon.count
                        if index < count {
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
                        } else if count % 2 == 1 && index < (count + 1) {
                            Color.clear
                                .frame(width: size.width / 2 - 20, height: 30, alignment: .topLeading)
                        } else if count == 0 && index < 2 {
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
    func BalnceCard(size: CGSize) -> some View {
        let balTotal = balanceService.getBalanceTotal()
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                .shadow(color: colorScheme == .dark ? .clear : .changeableShadow, radius: 5)
            VStack(alignment: .leading, spacing: 0) {
                Text("現在の残高")
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.leading, 10)
                    .padding(.top, 10)
                financeCharts.BalCompareChart(size: size)
                    .padding()
                Rectangle()
                    .fill(colorScheme == .dark ? Color(uiColor: .systemGray5) : .white)
                    .frame(height: 50)
                    .overlay {
                        HStack {
                            Text("残高合計")
                            Spacer()
                            Text("¥\(balTotal)")
                        }.padding(.horizontal, 20)
                            .font(.footnote)
                    }
            }.foregroundStyle(Color.changeableText)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

}



#Preview {
    ContentView()
}
