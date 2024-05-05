//
//  ReceiveAndPaymentView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/02/09.
//

import SwiftUI
import RealmSwift

struct ReceiveAndPaymentView: View {
    var accentColors: [Color]
    @Binding var incAmtTotal: Int
    @Binding var consAmtTotal: Int
    @State var date = Date()
    /** 操作 */
    // カレンダー
    @State var year = CalendarService().getOnlyComponent(date: Date(), component: .year)
    @State var month = CalendarService().getOnlyComponent(date: Date(), component: .month)
    // カレンダー・一覧切り替え
    @State var selectedList = true
    // 一覧収支情報切り替え
    @State var isAll = true
    @State var isInc = true
    // 収支情報削除
    @State var delIncConsDataAlertFlg = false
    @State var incConsKey = ""
    // service
    let incConsService = IncomeConsumeService()
    let calendarService = CalendarService()
    /** ビュー関連 */
    // 汎用ビュー
    let generalView = GeneralComponentView()
    @State private var selectSortText = "すべて"
    var body: some View {
        NavigationStack {
            GeometryReader {
                let safeAreaTop = $0.safeAreaInsets.top
                ScrollView {
                    VStack {
                        HeaderArea(safeAreaTop: safeAreaTop)
                        OptionHeader().padding(.vertical, 5)
                        switch selectedList {
                        case false:
                            CalendarView()
                        default:
                            IncomeConsumeListView()
                        }
                    }
                }.ignoresSafeArea()
                    .scrollDisabled(!selectedList)
            }
        }.alert("削除してよろしいですか。", isPresented: $delIncConsDataAlertFlg) {
            Button("削除", role: .destructive) {
                incConsService.deleteIncConsData(incConsKey: incConsKey)
                self.delIncConsDataAlertFlg = false
                self.incAmtTotal = incConsService.getIncOrConsAmtTotal(date:date , incFlg: true)
                self.consAmtTotal = incConsService.getIncOrConsAmtTotal(date: date, incFlg: false)
            }
            Button("キャンセル", role: .cancel) {
                self.delIncConsDataAlertFlg = false
            }
        }.onChange(of: date) {
            self.incAmtTotal = incConsService.getIncOrConsAmtTotal(date: date, incFlg: true)
            self.consAmtTotal = incConsService.getIncOrConsAmtTotal(date: date, incFlg: false)
            self.year = calendarService.getOnlyComponent(date: date, component: .year)
            self.month = calendarService.getOnlyComponent(date: date, component: .month)
            
        }.onAppear {
            self.date = Date()
        }
    }
    
    @ViewBuilder
    func HeaderArea(safeAreaTop: CGFloat) -> some View {
        let rectHeight: CGFloat = 210
        GeometryReader {
            let size = $0.size
            let minY = $0.frame(in: .scrollView).minY
            let maxHeight = size.height - (20 + 50 + 10)
            let progress = max(min((-minY / maxHeight), 1), 0)
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Text(String(year))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text("年")
                        .font(.caption.bold())
//                        .frame(maxHeight: 20, alignment: .bottom)
                    Text(String(month))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    Text("月")
                        .font(.caption.bold())
//                        .frame(maxHeight: 20, alignment: .bottom)
                    Spacer()
//                    Text("\(progress), \(maxHeight)")
                    Button(action: {
                        withAnimation {
                            self.date = calendarService.previewMonth(date: date)
                        }
                    }) {
                        Image(systemName: "chevron.left").font(.callout.bold())
                    }.padding(.trailing, 20)
                    Button(action: {
                        withAnimation {
                            self.date = calendarService.nextMonth(date: date)
                        }
                    }) {
                        Image(systemName: "chevron.right").font(.callout.bold())
                    }.padding(.leading, 20)
                }.foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.vertical, 10)
                ZStack {
                    generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                    HStack {
                        VStack {
                            Text("¥\(1000000)")
                                .font(.system(.callout,
                                              design: .rounded, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            Text("収入額合計")
                                .font(.caption2.bold())
                        }.padding(.horizontal, 10)
                        Rectangle().frame(width: 1, height: 50)
                        VStack {
                            Text("-¥\(10000000)")
                                .font(.system(.callout, design: .rounded, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            Text("支出額合計")
                                .font(.caption2.bold())
                        }.padding(.horizontal, 10)
                        Rectangle().frame(width: 1, height: 50)
                        VStack {
                            Text("-¥\(10000000)")
                                .font(.system(.callout, design: .rounded, weight: .bold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                            Text("収支合計")
                                .font(.caption2.bold())
                        }.padding(.horizontal, 10)
                    }.padding(.horizontal, 10)
                        .foregroundStyle(.white)
                }.padding(.horizontal, 20)
                    .frame(height: 100)
            }.padding(.vertical, 20)
                .frame(height: size.height - (maxHeight * progress), alignment: .top)
                .background(
                    LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint:.bottomTrailing)
                )
                .offset(y: -minY)
        }.frame(height: rectHeight)
            .zIndex(1000)
    }
    
    @ViewBuilder
    func OptionHeader() -> some View {
//        let sortText = ["すべて", "収入", "支出"]
        GeometryReader { geometry in
            let width = geometry.size.width
            HStack {
                Button(action: {
                    withAnimation {
                        self.selectedList.toggle()
                    }
                }) {
                    ZStack {
                        generalView.GradientCard(colors: accentColors, radius: 5)
                            .shadow(color: .changeableShadow, radius: 3)
                        HStack {
                            Text(self.selectedList ? "カレンダー" : "一覧")
                            Image(systemName: self.selectedList ? "calendar" : "list.bullet")
                        }.font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }.frame(width: width / 3, height: 25)
                Spacer()
            }.padding(.horizontal, 10)
        }.frame(height: 30)
    }
    
    @ViewBuilder
    func CalendarView() -> some View {
        let week = ["月", "火", "水", "木", "金", "土", "日"]
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                .frame(height: 300)
            VStack {
                HStack {
                    ForEach(week, id: \.self) { day in
                        Spacer()
                        Text(day)
                            .font(.caption2)
                            .foregroundStyle(Color.changeableText)
                        Spacer()
                    }
                }
                VStack(spacing: 0) {
                    let dates = calendarService.getDatesOfMonth(date: date)
                    let now = calendarService.getStringDate(date: Date(), format: "yyyyMMdd")
                    ForEach(1 ... 6, id: \.self) { row in
                        generalView.Border()
                            .foregroundStyle(.gray)
                        HStack(spacing: 0) {
                            ForEach(1 ... 7, id: \.self) { col in
                                let index = col + (row * 7) - 7
                                let calendarDate = dates[index - 1]
                                let dayStr = calendarService.getStringDate(date: calendarDate, format: "d")
                                let color = calendarService.getDayColor(index: index,
                                                                        row: row,
                                                                        selectDate: date,
                                                                        calendarDate: calendarDate)
                                let calendarDayStr = calendarService.getStringDate(date: calendarDate,
                                                                            format: "yyyyMMdd")
                                ZStack(alignment: .top) {
                                    Rectangle()
                                        .foregroundColor(.clear)
                                    VStack {
                                        ZStack {
                                            Circle()
                                                .frame(width: 20)
                                                .foregroundStyle(now == calendarDayStr ? accentColors.last ?? .clear : Color.clear)
                                            Text(dayStr)
                                                .font(.system(.caption, design: .rounded))
                                                .foregroundStyle(now == calendarDayStr ? .white : color)
                                        }.padding(.top, 5)
                                        VStack {
                                            let incPerDay = incConsService.getIncConsAmtTotalPerDay(dateStr: calendarDayStr, incFlg: true)
                                            let consPerDay = incConsService.getIncConsAmtTotalPerDay(dateStr: calendarDayStr, incFlg: false)
                                            let exsistInc = incConsService.isExsistIncConsData(dateStr: calendarDayStr, incFlg: true)
                                            let exsistCons = incConsService.isExsistIncConsData(dateStr: calendarDayStr, incFlg: false)
                                            let isDifferentMonth = calendarService.isDifferentMonth(selectDate: date, calendarDate: calendarDate)
                                            Group {
                                                Text(exsistInc ? "\(incPerDay)" : "")
                                                    .foregroundStyle(isDifferentMonth ? .gray : .blue)
                                                Text(exsistCons ? "\(consPerDay)" : "")
                                                    .foregroundStyle(isDifferentMonth ? .gray : .red)
                                            }.font(.system(.caption2, design: .rounded))
                                                .lineLimit(1)
                                                .minimumScaleFactor(0.5)
                                                .padding(.horizontal, 10)
                                        }
                                    }
                                }.onTapGesture {
                                    
                                }
                            }
                        }
                    }
                }
            }.padding(.horizontal, 15)
                    .padding(.vertical, 30)
        }.padding(.horizontal, 5)
    }
    
    @ViewBuilder
    func IncomeConsumeListView() -> some View {
        let incConsDic: [String: [Int]] =
                                IncomeConsumeService().getIncConsTotalPerDate(selectDate: date)
        GeometryReader { geometry in
            let width = geometry.size.width
            LazyVStack {
                if incConsDic.isEmpty {
                    Text("今月の情報がありません。")
                        .padding(.top, 100)
                } else {
                    ForEach(incConsDic.sorted(by: {$0.key > $1.key}), id: \.key) { key, value in
                        let day = incConsService.treatDateText(dateStr: key)
                        let incTotal = incConsDic.isEmpty ? 0 : incConsDic[key]![0]
                        let consTotal = incConsDic.isEmpty ? 0 : incConsDic[key]![1]
                        let incConsTotal = incConsDic.isEmpty ? 0 : incConsDic[key]![2]
                        Text(day)
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.changeableText)
                            .frame(maxWidth: width - 40, alignment: .leading)
                        HStack {
                            Rectangle().frame(width: 1)
                                .padding(.horizontal, 20)
                            ZStack {
                                generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 5)
                                HStack {
                                    VStack {
                                        Text("¥\(incConsTotal)")
                                            .foregroundStyle(incConsTotal < 0 ? .red : incConsTotal == 0 ?
                                                             Color.changeableText : .blue)
                                        Text("¥\(incTotal)")
                                            .foregroundStyle(incTotal > 0 ? .blue : .changeableText)
                                        Text("¥\(consTotal)")
                                            .foregroundStyle(consTotal > 0 ? .red : .changeableText)
                                    }.font(.system(.caption, design: .rounded, weight: .bold))
                                    Image(systemName: "chevron.right")
                                }
                            }
                        }.frame(height: 80)
                    }
                }
            }.padding(.horizontal, 20)
        }
    }
}

#Preview {
    @State var incAmtTotal = IncomeConsumeService().getIncOrConsAmtTotal(date: Date(), incFlg: true)
    @State var consAmtTotal = IncomeConsumeService().getIncOrConsAmtTotal(date: Date(), incFlg: false)
//    @State var date = CalendarService().previewMonth(date: Date())
    @State var date = Date()
    return ReceiveAndPaymentView(accentColors: [.purple, .indigo],
                                 incAmtTotal: $incAmtTotal,
                                 consAmtTotal: $consAmtTotal)
}
