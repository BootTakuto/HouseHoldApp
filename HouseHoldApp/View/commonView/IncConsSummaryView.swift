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
                    switch self.chartIndex {
                    case 0:
                        IncConsCompareChart(size: size)
                    case 1:
                        IncOrConsChartList(size: size, houseHoldType: 0)
                    case 2:
                        IncOrConsChartList(size: size, houseHoldType: 1)
                    default:
                        IncConsCompareChart(size: size)
                    }
                }.frame(maxWidth: .infinity)
                    .navigationBarBackButtonHidden(true)
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
            VStack {
                HStack {
                    Button(action: {
                        self.isPresentedFlg = false
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                            .fontWeight(.bold)
                    }
                    Spacer()
                }.padding(.bottom, 10)
                DateSelector()
                SelectorTab(size: size)
            }.frame(maxHeight: navigationHeight ,alignment: .top)
            .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    func DateSelector() -> some View {
        let dateStr = calendarService.getStringDate(date: selectDate, format: "yyyy年MM月")
        HStack {
            Text(dateStr)
                .foregroundStyle(.white)
                .fontWeight(.bold)
            Spacer()
            Button(action: {
                withAnimation {
                    self.selectDate = calendarService.previewMonth(date: selectDate)
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
            }.padding(.trailing, 5)
            Button(action: {
                withAnimation {
                    self.selectDate = calendarService.nextMonth(date: selectDate)
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.white)
                    .fontWeight(.bold)
            }.padding(.leading, 5)
        }
    }
    
    @ViewBuilder
    func SelectorTab(size: CGSize) -> some View {
        let texts = ["月別推移", "収入構成", "支出構成"]
        let imageNms = ["chart.bar.xaxis.ascending", "chart.pie.fill", "chart.pie.fill"]
        ScrollView(.horizontal) {
            HStack(spacing: 5) {
                ForEach(texts.indices, id: \.self) { index in
                    ZStack {
                        if self.chartIndex != index {
                            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 25)
                        } else {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(.changeable)
                        }
                        HStack {
                            Text(texts[index])
                            Spacer()
                            Image(systemName: imageNms[index])
                        }.padding(.horizontal, 20)
                        .font(.caption)
                        .foregroundStyle(self.chartIndex != index ? .white : .changeableText)
                    }.frame(width: abs((size.width - 40) / 3))
                        .onTapGesture {
                            withAnimation {
                                self.chartIndex = index
                            }
                        }
                }
            }.frame(height: 30)
        }.scrollIndicators(.hidden)
    }
    
    @ViewBuilder
    func IncConsCompareChart(size: CGSize) -> some View {
        ScrollView {
            VStack {
                ScrollView(.horizontal) {
                    charts.IncConsCompareChart(selectDate: selectDate, makeSize: 12)
                        .frame(minWidth: size.width * 2, minHeight: 200)
                        .padding(10)
                }.defaultScrollAnchor(.trailing)
            }
        }
    }
    
    @ViewBuilder
    func IncOrConsChartList(size: CGSize, houseHoldType: Int) -> some View {
        let chartDic = incConsService.getIncConsDataForChart(houseHoldType: houseHoldType, selectDate: selectDate)
        ScrollView {
            VStack {
                charts.IncConsRateChart(houseHoldType: houseHoldType, date: self.selectDate)
                    .padding()
                    .frame(height: 200)
                ForEach(chartDic.sorted(by: >), id: \.key) { key, value in
                    let sectionData = incConsService.getIncConsSec(pkey: key)
                    let color = ColorAndImage.colors[sectionData.incConsSecColorIndex]
                    let imageNm = sectionData.incConsSecImage
                    let secNm = sectionData.incConsSecName
                    ZStack {
                        generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                        HStack {
                            generalView.RoundedIcon(radius: 5, color: color,image: imageNm, text: secNm)
                                .frame(width: 40, height: 40)
                            
                            Text("¥\(value)")
                                .frame(maxWidth: size.width - 40 / 2, alignment: .trailing)
                                .foregroundStyle(Color.changeableText)
                                .fontDesign(.rounded)
                                .fontWeight(.bold)
                        }.padding(10)
                    }.padding(.horizontal, 10)
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
