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
                    Header()
                    ScrollView {
                        VStack {
                            generalView.Border()
                                .foregroundStyle(Color(uiColor: .systemGray3))
                                .padding(.horizontal, 20)
                            BalanceChartArea(size: size)
                                .padding(.bottom, 10)
//                                .compositingGroup()
//                                .shadow(color: .changeableShadow, radius: 5)
//                            FixedCostArea(size: size)
//                                .padding(.bottom, 10)
//                                .compositingGroup()
//                                .shadow(color: .changeableShadow, radius: 5)
                            generalView.Border()
                                .foregroundStyle(Color(uiColor: .systemGray3))
                                .padding(.horizontal, 20)
                            BudgetArea(size: size)
                                .padding(.bottom, 10)
                            generalView.Border()
                                .foregroundStyle(Color(uiColor: .systemGray3))
                                .padding(.horizontal, 20)
                            IncConsChartArea(size: size)
                                .padding(.bottom, 10)
                            generalView.Border()
                                .foregroundStyle(Color(uiColor: .systemGray3))
                                .padding(.horizontal, 20)
                                .padding(.bottom, 100)
                        }
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
        HStack(spacing: 0) {
            Text("ホーム")
                .font(.title.bold())
            Spacer()
            VStack {
                Image(systemName: "questionmark.circle")
                Text("使い方")
                    .font(.caption2)
            }
        }.foregroundStyle(Color.changeableText)
            .padding(.bottom, 20)
          .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    func DispHeadline(text: String, dispFlgIndex: Int, isExprain: Bool, exprain: String) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(text)
                    .font(.title3)
                    .fontWeight(.medium)
                if isExprain {
                    Text(exprain)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            Spacer()
            Image(systemName: "chevron.down")
                .rotationEffect(.degrees(self.dispFlg[dispFlgIndex] ? 180 : 0))
        }.foregroundStyle(Color.changeableText)
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
            DispHeadline(text: "残 高", dispFlgIndex: 0, isExprain: true,
                         exprain: "現時点での残高を把握できます")
            if self.dispFlg[0] {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(Array(balResults.sorted(by: {$0.balanceAmt > $1.balanceAmt})), id: \.self) { result in
                            miniBalIcon(balResult: result)
                        }
                    }.padding(.horizontal, 5)
                        .padding(.vertical, 8)
                }
//                HStack(spacing: 0) {
//                    Text("合計")
//                        .foregroundStyle(Color.changeableText)
//                        .frame(width: abs((size.width - 60) / 2), alignment: .leading)
//                    Text("¥\(balTotal)")
//                        .foregroundStyle(balTotal > 0 ? .blue : .red)
//                        .frame(width: abs((size.width - 60) / 2), alignment: .trailing)
//                        .lineLimit(1)
//                        .minimumScaleFactor(0.5)
//                } .font(.subheadline.bold())
//                    .frame(width: abs(size.width - 40))
//                    .padding(.vertical)
//                    .background(Color(uiColor: .systemGray6))
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                    .shadow(color: colorScheme == .dark ? .clear : Color(uiColor: .systemGray3),
//                            radius: colorScheme == .dark ? 0 : 5)
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
    
    /**▼固定費**/
//    @ViewBuilder
//    func FixedCostArea(size: CGSize) -> some View {
//        let fixedCostTotal = 25000
//        VStack(alignment: .trailing) {
//            DispHeadline(text: "固定費", dispFlgIndex: 1, isExprain: false, exprain: "")
//            if self.dispFlg[1] {
//                ScrollView(.horizontal) {
//                    HStack(spacing: 10) {
//                        ForEach(0 ..< 5, id: \.self) { index in
//                            FixedCostCard(incConsModel: IncomeConsumeModel())
//                        }
//                    }.padding(3)
//                }.padding(.top, 10)
//                HStack(spacing: 0) {
//                    Text("合計")
//                        .foregroundStyle(Color.changeableText)
//                        .frame(width: abs((size.width - 60) / 2), alignment: .leading)
//                    Text("¥\(fixedCostTotal)")
//                        .foregroundStyle(.red)
//                        .frame(width: abs((size.width - 60) / 2), alignment: .trailing)
//                        .lineLimit(1)
//                        .minimumScaleFactor(0.5)
//                }.font(.subheadline.bold())
//                    .frame(width: abs(size.width - 40))
//                    .padding(.vertical)
//                    .background(.changeable)
//                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                generalView.glassTextRounedButton(color: accentColors.last ?? .blue, text: "設定", imageNm: "", radius: 25) {
//                    
//                }.frame(width: 100, height: 25)
//                    .compositingGroup()
//                    .shadow(color: .changeableShadow, radius: 3)
//                    .padding(.top, 5)
//            }
//        }.padding(10)
//                .padding(.vertical, 10)
//    }
    
//    @ViewBuilder
//    func FixedCostCard(incConsModel: IncomeConsumeModel) -> some View {
//        let rectWidth: CGFloat = 100
//        let rectHeight: CGFloat = 80
//        let secResult = incConsCatgService.getIncConsSecSingle(secKey: incConsModel.incConsSecKey)
//        let color = ColorAndImage.colors[secResult.incConsSecColorIndex]
//        ZStack {
//            Color.changeable
//            VStack {
//                HStack {
//                    generalView.RoundedIcon(radius: 5, color: color,
//                                            image: secResult.incConsSecImage, text: secResult.incConsSecName)
//                    .frame(width: 30, height: 30)
//                    Text(secResult.incConsSecName)
//                        .font(.caption)
//                        .foregroundStyle(Color.changeableText)
//                }
//                Text("2024/5/21")
//                    .font(.system(.caption, design: .rounded))
//                    .foregroundStyle(Color.changeableText)
//                    .frame(width: rectWidth - 10, alignment: .trailing)
//                Text("¥\(5000)")
//                    .font(.system(.caption, design: .rounded, weight: .bold))
//                    .foregroundStyle(Color.red)
//                    .frame(width: rectWidth - 10, alignment: .trailing)
//                
//            }
//        }.frame(width: rectWidth, height: rectHeight)
//            .clipShape(RoundedRectangle(cornerRadius: 10))
//            .compositingGroup()
//            .shadow(color: .changeableShadow, radius: 3)
//    }
    
    /**▼予算 **/
    @ViewBuilder
    func BudgetArea(size: CGSize) -> some View {
        VStack(alignment: .trailing) {
            DispHeadline(text: "予 算", dispFlgIndex: 2, isExprain: true, exprain: "予算を設定し、支出を管理しましょう")
            if self.dispFlg[2] {
                HStack {
                    Text("予算(固定費を含む)")
                        .foregroundStyle(Color.changeableText)
                    Spacer()
                    Text("¥\(30000)")
                        .fontDesign(.rounded)
                        .foregroundStyle(Color.changeableText)
                }.font(.subheadline)
                    .fontWeight(.medium)
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
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.changeableText)
                ZStack {
                    Group {
                        let rate: CGFloat = 12000 / 30000
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color(uiColor: .systemGray6)
                                .shadow(.inner(color: .gray, radius: 1))
                            ).frame(height: 15)
                        generalView.GradientCard(colors: accentColors, radius: 25)
                            .frame(width: abs((size.width - 46) * rate), height: 10)
                            .padding(.horizontal, 3)
                    }.frame(width: abs(size.width - 40), alignment: .trailing)
                }
                generalView.glassTextRounedButton(color: .changeableText, text: "設 定", imageNm: "", radius: 25) {
                    
                }.frame(width: 100, height: 25)
                    .compositingGroup()
//                    .shadow(color: .changeableShadow, radius: 3)
                    .padding(.top, 5)
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
            let dateStr = calendarService.getStringDate(date: selectDate, format: "yyyy年M月")
            DispHeadline(text: "収入・支出" + " (" + dateStr + ") ", dispFlgIndex: 3, isExprain: true,
                         exprain: "今月の収入・支出を確認できます")
            if self.dispFlg[3] {
                ScrollView(.horizontal) {
                    let texts = ["収入合計", "支出合計", "収入 - 支出"]
                    let incTotal = incConsService.getIncOrConsAmtTotal(date: selectDate, houseHoldType: 0)
                    let consTotal = incConsService.getIncOrConsAmtTotal(date: selectDate, houseHoldType: 1)
                    let gapTotal = incTotal - consTotal
                    let amts = [incTotal, consTotal, gapTotal]
                    HStack {
                        ForEach(0 ..< 3, id: \.self) { index in
                            incConsBalMiniIcon(isKindFlg: index, label: texts[index], amt: amts[index])
                        }
                    }.padding(.horizontal, 5)
                        .padding(.vertical, 8)
                }
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
