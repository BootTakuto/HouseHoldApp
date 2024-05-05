//
//  WholeSummary.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2023/08/31.
//

import SwiftUI
import Charts

struct WholeSummary: View {
    var accentColors: [Color]
    @State private var selectChart = 0
    @State private var selectDate = Date()
    @State private var chartIndex = 0
    // 画面操作
    @State var dispFlg = [true, true, true, true]
    @State var assetsChartDestFlg = false
    @State var incConsChartDestFlg = false
    // charts
    let financeCharts = FinanceCharts()
    // 汎用ビュー
    let generalView = GeneralComponentView()
    // service
    let calendarService = CalendarService()
    // 遷移情報
    @State var chartPageFlg = false
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                VStack(spacing: 0) {
                    Header()
                    
                    ScrollView {
                        ChartArea(size: size)
                            .padding(.bottom, 10)
                        BudgetArea()
                    }.padding(.horizontal, 10)
                }
            }.navigationDestination(isPresented: $assetsChartDestFlg) {
                
            }.navigationDestination(isPresented: $incConsChartDestFlg) {
                IncConsSummaryView(accentColors: accentColors,
                                   isPresentedFlg: $incConsChartDestFlg,
                                   chartIndex: chartIndex)
            }
        }
    }
    
    /**▼共通view**/
    @ViewBuilder
    func Header() -> some View {
        let year: Int = calendarService.getOnlyComponent(date: selectDate, component: .year)
        let month: Int = calendarService.getOnlyComponent(date: selectDate, component: .month)
        HStack(spacing: 0) {
            Text(String(year))
                .font(.system(.title2, design: .rounded, weight: .bold))
            Text("年")
                .font(.caption.bold())
            Text(String(month))
                .font(.system(.title2, design: .rounded, weight: .bold))
            Text("月")
                .font(.caption.bold())
            Spacer()
//            Group {
//                Button(action: {
//                    withAnimation {
//                        self.selectDate = calendarService.previewMonth(date: selectDate)
//                    }
//                }) {
//                    Image(systemName: "chevron.left")
//                }.padding(.trailing, 20)
//                Button(action: {
//                    withAnimation {
//                        self.selectDate = calendarService.nextMonth(date: selectDate)
//                    }
//                }) {
//                    Image(systemName: "chevron.right")
//                }
//            }.fontWeight(.bold)
        }.foregroundStyle(Color.changeableText)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.bottom, 20)
    }
    
    @ViewBuilder
    func DispHeadline(text: String, dispFlgIndex: Int) -> some View {
        HStack {
            Text(text)
            Spacer()
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(self.dispFlg[dispFlgIndex] ? 180 : 0))
        }.font(.subheadline.bold())
            .foregroundStyle(Color.changeableText)
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    self.dispFlg[dispFlgIndex].toggle()
                }
            }
    }
    
    /**▼チャートエリア構成**/
    @ViewBuilder
    func SelectorTab() -> some View {
        let text = ["残高割合", "収支推移"]
        HStack {
            ForEach(text.indices, id:\.self) {index in
                ZStack {
                    if self.selectChart == index {
                        generalView.GradientCard(colors: accentColors, radius: 25)
                    } else {
                        generalView.GlassBlur(effect: .systemMaterial, radius: 25)
                    }
                    RoundedRectangle(cornerRadius: 25)
                        .fill(
                            .linearGradient(colors: self.selectChart == index ? accentColors : [.changeable], startPoint: .topLeading, endPoint: .bottomTrailing))
                    HStack {
                        Text(text[index])
                            .fontWeight(.bold)
                        Image(systemName: "triangle.fill")
                            .rotationEffect(.degrees(180))
                    }.font(.caption2)
                        .foregroundStyle(index == self.selectChart ? .white : .changeableText)
                }.contentShape(Rectangle())
                .onTapGesture {
                    withAnimation {
                        self.selectChart = index
                    }
                }
                .frame(width: 120, height: 30)
            }
        }
    }
    
    @ViewBuilder
    func ChartCard(size: CGSize, index: Int) -> some View {
        let assetsChartTitles = ["純資産割合", "資産構成", "負債構成"]
        let incConsChartTitles = ["収支比較", "収入構成", "支出構成"]
        let assetsChartExplains = ["資産・負債残高の割合から\n現在の純資産を把握",
                                   "資産の構成割合を把握\n", "負債の構成割合を把握\n"]
        let incConsChartsExplains = ["収入・支出を比較し\n収支情報を確認", "収入の構成割合を把握\n",
                                     "支出の構成割合を把握\n"]
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 0)
            VStack(spacing: 0) {
                ZStack(alignment: .bottom) {
                    if self.selectChart == 0 {
                        switch index {
                        case 0:
                            financeCharts.BalCompareChart().padding()
                        case 1:
                            financeCharts.BalRateChart(assetsFlg: true).padding()
                        case 2:
                            financeCharts.BalRateChart(assetsFlg: false).padding()
                        default:
                            financeCharts.BalCompareChart().padding()
                        }
                    } else {
                        switch index {
                        case 0:
                            financeCharts.IncConsCompareChart(selectDate: Date(), makeSize: 2).padding()
                        case 1:
                            financeCharts.IncConsRateChart(incFlg: true, date: Date()).padding()
                        case 2:
                            financeCharts.IncConsRateChart(incFlg: false, date: Date()).padding()
                        default:
                            financeCharts.IncConsCompareChart(selectDate: Date(), makeSize: 2).padding()
                        }
                    }
                    Color(uiColor: .systemGray5)
                        .blur(radius: 20)
                        .frame(height: 250 / 5)
                    VStack(alignment: .leading) {
                        Text(self.selectChart == 0 ? assetsChartTitles[index] : incConsChartTitles[index])
                        Text(self.selectChart == 0 ? assetsChartExplains[index] : incConsChartsExplains[index])
                            .font(.caption)
                    }.padding(.bottom, 5)
                        .frame(maxWidth: 200 - 20, alignment: .leading)
                }
                ZStack {
                    Rectangle()
                        .fill(.linearGradient(colors: [.changeable, .changeable.opacity(0.8)],
                                              startPoint: .bottom, endPoint: .top))
                        .frame(height: 40)
                    HStack {
                        Text("詳細")
                        Spacer()
                        Image(systemName: "chevron.right")
                    }.padding(.horizontal, 20)
                        .font(.caption.bold())
                        .foregroundStyle(Color.changeableText)
                }
            }
        }.clipShape(RoundedRectangle(cornerRadius: 10))
            .frame(width: abs(size.width - 100), height: 250)
            .padding(.horizontal, 10)
            .compositingGroup()
            .shadow(color: .changeableShadow, radius: 3)
    }
    
    @ViewBuilder
    func ChartArea(size: CGSize) -> some View {
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial,
                                  radius: 10)
            VStack {
                DispHeadline(text: "資産・収支推移", dispFlgIndex: 0)
                if self.dispFlg[0] {
                    SelectorTab()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    ScrollView(.horizontal) {
                        HStack(spacing: 0) {
                            if self.selectChart == 0 {
                                ForEach (0 ..< 3, id: \.self) { index in
                                    ChartCard(size: size, index: index)
                                        .onTapGesture {
                                            self.chartIndex = index
                                            self.assetsChartDestFlg = true
                                        }
                                }
                            } else {
                                ForEach (0 ..< 3, id: \.self) {index in
                                    ChartCard(size: size, index: index)
                                        .onTapGesture {
                                            self.chartIndex = index
                                            self.incConsChartDestFlg = true
                                        }
                                }
                            }
                        } .padding(.vertical, 15)
                            .padding(.horizontal, 15)
                            .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                        .scrollIndicators(.hidden)
                }
            }.padding(10)
                .padding(.vertical, 10)
        }
    }
    
    /**▼予算エリア構成**/
    @ViewBuilder
    func BudgetArea() -> some View {
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial,
                                  radius: 10)
            VStack {
                DispHeadline(text: "予算設定", dispFlgIndex: 1)
            }.padding(10)
                .padding(.vertical, 10)
        }
    }
}



#Preview {
    ContentView()
}
