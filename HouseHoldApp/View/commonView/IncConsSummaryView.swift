//
//  IncConsSummaryView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/04/24.
//

import SwiftUI
import RealmSwift

struct IncConsSummaryView: View {
    var accentColors: [Color]
    @Binding var isPresentedFlg: Bool
    @State var chartIndex: Int
    @State var selectDate = Date()
    @Environment(\.colorScheme) var colorScheme
    @State var isMonthSummary = true
    @State var selectTerm = 0
    @State var totalDispFlgs = IncomeConsumeService().getMonthTotalDispFlg()
    @State var year = CalendarService().getOnlyComponent(date: Date(), component: .year)
    // service
    let incConsService = IncomeConsumeService()
    let calendarService = CalendarService()
    // view設定
    let navigationHeight: CGFloat = 110
    // 汎用view
    let charts = FinanceCharts()
    let generalView = GeneralComponentView()
    
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                VStack(spacing: 0) {
                    Header(size: size)
                    if (isMonthSummary) {
                        TabView (selection: $chartIndex) {
                            IncOrConsChartList(size: size, houseHoldType: 0)
                                .tag(0)
                            IncOrConsChartList(size: size, houseHoldType: 1)
                                .tag(1)
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    } else {
                        TabView (selection: $chartIndex) {
                            IncConsCompareChartByYear(size: size)
                                .tag(0)
                            IncOrConsChartList(size: size, houseHoldType: 0)
                                .tag(1)
                            IncOrConsChartList(size: size, houseHoldType: 1)
                                .tag(2)
                        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    }
                }.frame(maxWidth: .infinity)
                    .navigationBarBackButtonHidden(true)
            }.ignoresSafeArea(edges: [.bottom])
        }.onChange(of: selectTerm) {
            withAnimation {
                self.isMonthSummary = selectTerm == 0
                self.chartIndex = 0
            }
        }.onChange(of: selectTerm) {
            if !isMonthSummary {
                self.year = calendarService.getOnlyComponent(date: selectDate, component: .year)
            } else {
                let month = calendarService.getOnlyComponent(date: selectDate, component: .month)
                self.selectDate = calendarService.getSettingDate(year: year, month: month)
            }
        }
    }
    
    @ViewBuilder
    func Header(size: CGSize) -> some View {
        ZStack {
            LinearGradient(colors: accentColors,
                           startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            .frame(height: navigationHeight)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        self.isPresentedFlg = false
                    }) {
                        Image(systemName: "arrow.left")
                            .foregroundStyle(.white)
                    }
                    SegmentedPicker(selection: $selectTerm,
                                    texts: ["月間収支", "年間収支"],
                                    defaultTextColor: .white,
                                    selectTextColor: .changeableText,
                                    backColor: .changeable.opacity(0.25),
                                    selectRectColor: .changeable)
                    .padding(.horizontal,50)
                    .padding(.trailing, 20)
                }
                DateSelector()
                    .padding(.vertical, 10)
                if (isMonthSummary) {
                    SelectorTabMonthSummery(size: size)
                } else {
                    SelectorTabYearSummery(size: size)
                }
            }.frame(maxHeight: navigationHeight ,alignment: .top)
                .padding(.horizontal, 10)
        }
    }
    
    @ViewBuilder
    func DateSelector() -> some View {
        let str_yyyyMM = calendarService.getStringDate(date: selectDate, format: "yyyy年MM月")
        let str_yyyy = String(year)
        HStack {
            Text(isMonthSummary ? str_yyyyMM : str_yyyy)
                .foregroundStyle(.white)
                .fontWeight(.bold)
                .onTapGesture {
                    withAnimation {
                        
                    }
                }
            Spacer()
            Button(action: {
                withAnimation {
                    if isMonthSummary {
                        self.selectDate = calendarService.previewMonth(date: selectDate)
                    } else {
                        if self.year >= 1900 {
                            self.year -= 1
                        }
                    }
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
            }.padding(.trailing, 5)
            Button(action: {
                withAnimation {
                    if isMonthSummary {
                        self.selectDate = calendarService.nextMonth(date: selectDate)
                    } else {
                        if self.year <= 2100 {
                            self.year += 1
                        }
                    }
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
            }.padding(.leading, 5)
        }
    }
    
    @ViewBuilder
    func SelectorTabMonthSummery(size: CGSize) -> some View {
        let texts = ["収入構成", "支出構成"]
        let imageNms = ["chart.pie.fill", "chart.pie.fill"]
        GeometryReader {
            let size = $0.size
            let colSpan = size.width / 6
            let offsets: [CGFloat] = [colSpan - (colSpan / 4),
                                      colSpan * 4 - (colSpan / 4)]
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 0) {
                    ForEach(texts.indices, id: \.self) { index in
                        HStack {
                            Text(texts[index])
                            Image(systemName: imageNms[index])
                        }.frame(width: size.width / 2)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .onTapGesture {
                                withAnimation {
                                    self.chartIndex = index
                                }
                            }
                    }
                }
                RoundedRectangle(cornerRadius: .infinity)
                    .frame(width: size.width / 6 + 30, height: 5)
                    .animation(.spring, value: chartIndex)
                    .offset(x: offsets[chartIndex])
            }.foregroundStyle(.white)
        }
    }
    
    @ViewBuilder
    func SelectorTabYearSummery(size: CGSize) -> some View {
        let texts = ["収支比較", "収入構成", "支出構成"]
        let imageNms = ["chart.bar.xaxis.ascending", "chart.pie.fill", "chart.pie.fill"]
        GeometryReader {
            let size = $0.size
            let colSpan = size.width / 9
            let offsets: [CGFloat] = [colSpan - (colSpan / 3),
                                      colSpan * 4 - (colSpan / 3),
                                      colSpan * 7 - (colSpan / 3)]
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    ForEach(texts.indices, id: \.self) { index in
                        HStack {
                            Text(texts[index])
                            Image(systemName: imageNms[index])
                        }.frame(width: size.width / 3)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .onTapGesture {
                                withAnimation {
                                    self.chartIndex = index
                                }
                            }
                    }
                }
                RoundedRectangle(cornerRadius: .infinity)
                    .frame(width: size.width / 9 + 30, height: 5)
                    .animation(.spring, value: chartIndex)
                    .offset(x: offsets[chartIndex])
            }.foregroundStyle(.white)
        }
    }
    
    @ViewBuilder
    func IncConsCompareChartByYear(size: CGSize) -> some View {
        ScrollView {
            VStack {
                ScrollView(.horizontal) {
                    charts.YearIncConsCompareChart(year: year)
                        .frame(minWidth: size.width - 20, minHeight: 200)
                }.defaultScrollAnchor(.trailing)
                HStack {
                    Text("年間合計")
                        .fontWeight(.medium)
                    Spacer()
                }.foregroundStyle(Color.changeableText)
                ZStack {
                    generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 5)
                        .frame(width: .infinity, height: 100)
                    VStack(alignment: .trailing) {
                        let yearIncTotal = incConsService.getYearIncOrConsAmtTotal(year: year, houseHoldType: 0)
                        let yearConsTotal = incConsService.getYearIncOrConsAmtTotal(year: year, houseHoldType: 1)
                        HStack {
                            Text("収入")
                                .foregroundStyle(Color.blue)
                            Spacer()
                            Text("¥\(yearIncTotal)")
                                .foregroundStyle(Color.changeableText)
                        }.padding(.horizontal, 20)
                        generalView.Border()
                            .foregroundStyle(Color(uiColor: .systemGray3))
                            .padding(.leading, 10)
                        HStack {
                            Text("支出")
                                .foregroundStyle(Color.red)
                            Spacer()
                            Text("¥\(yearConsTotal)")
                                .foregroundStyle(Color.changeableText)
                        }.padding(.horizontal, 20)
                    }
                }
                ForEach (1 ... 12, id: \.self) { month in
                    let date = calendarService.getSettingDate(year: year, month: month)
                    let monthIncTotal = incConsService.getMonthIncOrConsAmtTotal(date: date, houseHoldType: 0)
                    let monthConsTotal = incConsService.getMonthIncOrConsAmtTotal(date: date, houseHoldType: 1)
                    let index = month - 1
                    HStack {
                        Text("\(month)月")
                            .fontWeight(.medium)
                        Spacer()
                        Button(action: {
                            withAnimation {
                                totalDispFlgs[month].toggle()
                            }
                        }) {
                            Image(systemName: "chevron.down")
                        }.font(.footnote)
                    }.foregroundStyle(Color.changeableText)
                    if totalDispFlgs[index] == true {
                        ZStack {
                            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 5)
                                .frame(width: .infinity, height: 100)
                            VStack(alignment: .trailing) {
                                HStack {
                                    Text("収入")
                                        .foregroundStyle(Color.blue)
                                    Spacer()
                                    Text("¥\(monthIncTotal)")
                                        .foregroundStyle(Color.changeableText)
                                }.padding(.horizontal, 20)
                                generalView.Border()
                                    .foregroundStyle(Color(uiColor: .systemGray3))
                                    .padding(.leading, 10)
                                HStack {
                                    Text("支出")
                                        .foregroundStyle(Color.red)
                                    Spacer()
                                    Text("¥\(monthConsTotal)")
                                        .foregroundStyle(Color.changeableText)
                                }.padding(.horizontal, 20)
                            }
                        }
                    }
                }
            }.padding(10)
            
        }.scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    func IncOrConsChartList(size: CGSize, houseHoldType: Int) -> some View {
        let chartDic = isMonthSummary ?
        incConsService.getMonthIncConsDataForChart(houseHoldType: houseHoldType, selectDate: selectDate) :
        incConsService.getYearIncConsDataForChart(houseHoldType: houseHoldType, year: year)
        ScrollView {
            VStack {
                ZStack {
                    generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                        .shadow(color: colorScheme == .dark ? .clear : .changeableShadow, radius: 5)
                        .padding(.horizontal, 20)
                    HStack(spacing: 0) {
                        if isMonthSummary {
                            charts.MonthIncConsRateChart(houseHoldType: houseHoldType, date: self.selectDate)
                                .padding()
                                .frame(width: 200, height: 200)
                        } else {
                            charts.YearIncConsRateChart(houseHoldType: houseHoldType, year: year)
                                .padding()
                                .frame(width: 200, height: 200)
                        }
                        VStack(alignment: .leading, spacing: 1) {
                            ForEach(chartDic.sorted {$0.value > $1.value}, id: \.key) { key, value in
                                let sectionData = incConsService.getIncConsSec(pkey: key)
                                let color = ColorAndImage.colors[sectionData.incConsSecColorIndex]
                                HStack {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 8, height: 8)
                                    Text(sectionData.incConsSecName)
                                        .font(.caption2)
                                        .foregroundStyle(Color.changeableText)
                                }
                            }
                        }.frame(width: 100)
                    }
                }.padding(.vertical, 20)
                ForEach(chartDic.sorted {$0.value > $1.value}, id: \.key) { key, value in
                    let sectionData = incConsService.getIncConsSec(pkey: key)
                    let color = ColorAndImage.colors[sectionData.incConsSecColorIndex]
                    let imageNm = sectionData.incConsSecImage
                    let secNm = sectionData.incConsSecName
                    HStack {
                        generalView.RoundedIcon(radius: 10, color: color,image: imageNm, text: "")
                            .frame(width: 40, height: 40)
                        Group {
                            Text(secNm)
                            Text("¥\(value)")
                                .frame(maxWidth: size.width - 40 / 2, alignment: .trailing)
                        }.foregroundStyle(Color.changeableText)
                    }.padding(.horizontal, 20)
                 }
            }
        }
    }
}

#Preview {
    @State var isPresentedFlg = false
    @State var chartIndex = 0
    return IncConsSummaryView(accentColors: [.purple, .indigo],
                              isPresentedFlg: $isPresentedFlg, chartIndex: 0)
}
