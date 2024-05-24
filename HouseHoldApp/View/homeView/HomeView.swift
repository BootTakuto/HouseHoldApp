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
    @State private var selectChart = 0
    @State private var selectDate = Date()
    @State private var chartIndex = 0
    // 画面操作
    @State var dispFlg = [true, true, true, true]
    @State var assetsChartDestFlg = false
    @State var incConsChartDestFlg = false
    /** 残高 */
    @State var balResults = BalanceService().getBalanceResults()
    // charts
    let financeCharts = FinanceCharts()
    // 汎用ビュー
    let generalView = GeneralComponentView()
    // service
    let calendarService = CalendarService()
    let balanceService = BalanceService()
    let incConsCatgService = IncConSecCatgService()
    // 遷移情報
    @State var chartPageFlg = false
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                VStack(spacing: 0) {
                    Header()
                    ScrollView {
                        VStack {
                            BalanceChartArea(size: size)
                                .padding(.bottom, 10)
                                .compositingGroup()
                                .shadow(color: .changeableShadow, radius: 5)
                            FixedCostArea(size: size)
                                .padding(.bottom, 10)
                                .compositingGroup()
                                .shadow(color: .changeableShadow, radius: 5)
                            BudgetArea(size: size)
                                .padding(.bottom, 10)
                                .compositingGroup()
                                .shadow(color: .changeableShadow, radius: 5)
                            IncConsChartArea(size: size)
                                .padding(.bottom, 100)
                                .compositingGroup()
                                .shadow(color: .changeableShadow, radius: 5)
                        }.padding(.horizontal, 10)
                            .padding(.top, 10)
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
    
    /** ▼残高チャート **/
    @ViewBuilder
    func miniBalIcon(balResult: BalanceModel) -> some View {
        HStack {
            Circle()
                .fill(ColorAndImage.colors[balResult.colorIndex])
                .frame(width: 15)
            VStack(alignment: .leading) {
                Text(balResult.balanceNm)
                    .font(.caption2.bold())
                    .foregroundStyle(Color.changeableText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                Text("¥\(balResult.balanceAmt)")
                    .font(.system(.caption2, design: .rounded, weight: .bold))
                    .foregroundStyle(balResult.balanceAmt > 0 ? .blue : .red)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }.frame(maxWidth: 100, alignment: .leading)
        }.padding(3)
            .padding(.horizontal, 5)
            .background(Color.changeable)
            .clipShape(RoundedRectangle(cornerRadius: 25))
//            .shadow(color: .changeableShadow, radius: 3)
    }
    
    @ViewBuilder
    func BalanceChartArea(size: CGSize) -> some View {
        let balTotal = balanceService.getBalanceTotal()
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
            VStack {
                DispHeadline(text: "残高", dispFlgIndex: 0)
                if self.dispFlg[0] {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(Array(balResults.sorted(by: {$0.balanceAmt > $1.balanceAmt})), id: \.self) { result in
                                miniBalIcon(balResult: result)
                            }
                        }.padding(3)
                    }.padding(.top, 10)
                    HStack(spacing: 0) {
                        Text("合計")
                            .foregroundStyle(Color.changeableText)
                            .frame(width: abs((size.width - 60) / 2), alignment: .leading)
                        Text("¥\(balTotal)")
                            .foregroundStyle(balTotal > 0 ? .blue : .red)
                            .frame(width: abs((size.width - 60) / 2), alignment: .trailing)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    } .font(.subheadline.bold())
                        .frame(width: abs(size.width - 40))
                        .padding(.vertical)
                        .background(.changeable)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    ZStack {
                        Color.changeable
                        ScrollView(.horizontal) {
                            HStack {
                                financeCharts.BalCompareChart()
                                    .padding(10)
                            }.frame(width: abs(size.width - 40), height: 180)
                        }.frame(height: 210)
                    }.clipShape(RoundedRectangle(cornerRadius: 10))
//                        .shadow(color: .changeableShadow, radius: 3)
                }
            }.padding(10)
                .padding(.vertical, 10)
        }
    }
    
    /**▼固定費**/
    @ViewBuilder
    func FixedCostArea(size: CGSize) -> some View {
        let fixedCostTotal = 25000
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
            VStack(alignment: .trailing) {
                DispHeadline(text: "固定費", dispFlgIndex: 1)
                if self.dispFlg[1] {
                    ScrollView(.horizontal) {
                        HStack(spacing: 10) {
                            ForEach(0 ..< 5, id: \.self) { index in
                                FixedCostCard(incConsModel: IncomeConsumeModel())
                            }
                        }.padding(3)
                    }.padding(.top, 10)
                    HStack(spacing: 0) {
                        Text("合計")
                            .foregroundStyle(Color.changeableText)
                            .frame(width: abs((size.width - 60) / 2), alignment: .leading)
                        Text("¥\(fixedCostTotal)")
                            .foregroundStyle(.red)
                            .frame(width: abs((size.width - 60) / 2), alignment: .trailing)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }.font(.subheadline.bold())
                        .frame(width: abs(size.width - 40))
                        .padding(.vertical)
                        .background(.changeable)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    generalView.glassTextRounedButton(color: accentColors.last ?? .blue, text: "設定", imageNm: "", radius: 25) {
                        
                    }.frame(width: 100, height: 25)
                        .compositingGroup()
                        .shadow(color: .changeableShadow, radius: 3)
                        .padding(.top, 5)
                }
            }.padding(10)
                .padding(.vertical, 10)
        }
    }
    
    @ViewBuilder
    func FixedCostCard(incConsModel: IncomeConsumeModel) -> some View {
        let rectWidth: CGFloat = 100
        let rectHeight: CGFloat = 80
        let secResult = incConsCatgService.getIncConsSecSingle(secKey: incConsModel.incConsSecKey)
        let color = ColorAndImage.colors[secResult.incConsSecColorIndex]
        ZStack {
            Color.changeable
            VStack {
                HStack {
                    generalView.RoundedIcon(radius: 5, color: color,
                                            image: secResult.incConsSecImage, text: secResult.incConsSecName)
                    .frame(width: 30, height: 30)
                    Text(secResult.incConsSecName)
                        .font(.caption)
                        .foregroundStyle(Color.changeableText)
                }
                Text("2024/5/21")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(Color.changeableText)
                    .frame(width: rectWidth - 10, alignment: .trailing)
                Text("¥\(5000)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .foregroundStyle(Color.red)
                    .frame(width: rectWidth - 10, alignment: .trailing)
                
            }
        }.frame(width: rectWidth, height: rectHeight)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .compositingGroup()
            .shadow(color: .changeableShadow, radius: 3)
    }
    
    /**▼予算 **/
    @ViewBuilder
    func BudgetArea(size: CGSize) -> some View {
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
            VStack(alignment: .trailing) {
                DispHeadline(text: "予算設定", dispFlgIndex: 2)
                if self.dispFlg[2] {
                    HStack {
                        Text("予算(固定費を含む)")
                            .foregroundStyle(Color.changeableText)
                        Spacer()
                        Text("¥\(30000)")
                            .fontDesign(.rounded)
                            .foregroundStyle(Color.changeableText)
                    }.font(.subheadline.bold())
                        .padding(.horizontal, 10)
                        .padding(.top, 10)
                    HStack {
                        Text("支出")
                        Text("¥\(18000)")
                            .fontDesign(.rounded)
                            .foregroundStyle(.red)
                        Spacer()
                        Text("残り")
                        Text("¥\(12000)")
                            .fontDesign(.rounded)
                    }.padding(.horizontal, 10)
                        .padding(.vertical, 1)
                        .font(.caption.bold())
                        .foregroundStyle(Color.changeableText)
                    ZStack {
                        Group {
                            let rate: CGFloat = 12000 / 30000
//                            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 25)
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(uiColor: .systemGray5)
                                    .shadow(.inner(color: .changeableShadow, radius: 1))
                                ).frame(height: 15)
                            generalView.GradientCard(colors: accentColors, radius: 25)
                                .frame(width: abs((size.width - 46) * rate), height: 10)
                                .padding(.horizontal, 3)
                        }.frame(width: abs(size.width - 40), alignment: .trailing)
                    }
                    generalView.glassTextRounedButton(color: accentColors.last ?? .blue, text: "設定", imageNm: "", radius: 25) {
                        
                    }.frame(width: 100, height: 25)
                        .compositingGroup()
                        .shadow(color: .changeableShadow, radius: 3)
                        .padding(.top, 5)
                }
            }.padding(10)
                .padding(.vertical, 10)
        }
    }
    
    /** ▼収支チャート **/
    @ViewBuilder
    func ChartCard(size: CGSize, index: Int) -> some View {
        let incConsChartTitles = ["収支比較", "収入構成", "支出構成"]
        let incConsChartsExplains = ["収入・支出を比較し\n収支情報を確認", "収入の構成割合を把握\n",
                                     "支出の構成割合を把握\n"]
        ZStack {
            Color.changeable
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
                    Color(uiColor: .systemGray5)
                        .blur(radius: 20)
                        .frame(height: 250 / 5)
                    VStack(alignment: .leading) {
                        Text(incConsChartTitles[index])
                        Text(incConsChartsExplains[index])
                            .font(.caption)
                    }.padding(.bottom, 5)
                        .frame(maxWidth: 300 - 50, alignment: .leading)
                        .foregroundStyle(Color.changeableText)
                }
                ZStack {
                    Rectangle()
                        .fill(.changeable)
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
    func IncConsChartArea(size: CGSize) -> some View {
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
            VStack {
                DispHeadline(text: "収入・支出", dispFlgIndex: 3)
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
                        } .padding(.vertical, 15)
                            .padding(.horizontal, 15)
                            .scrollTargetLayout()
                    }.scrollTargetBehavior(.viewAligned)
                        .scrollIndicators(.hidden)
                }
            }.padding(10)
                .padding(.vertical, 10)
        }
    }
    
}



#Preview {
    ContentView()
}
