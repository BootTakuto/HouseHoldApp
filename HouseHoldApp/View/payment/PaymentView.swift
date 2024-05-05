//
//  PaymentView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/04/09.
//

import SwiftUI
import RealmSwift

struct PaymentView: View {
    @State private var selectDate = Date()
    @State private var selectListView = true
    var accentColors: [Color]
    // service
    let incConsService = IncomeConsumeService()
    let calendarService = CalendarService()
    // view設定
    let generalView = GeneralComponentView()
    let dateSelectorHeight: CGFloat = 100
    let cardHeight: CGFloat = 100
    @State private var alertFlg = false
    // 遷移情報
    @State var detailPageFlg = false
    @State var incConsObject: IncomeConsumeModel = IncomeConsumeModel()
    @State var incConsDic = IncomeConsumeService().getIncConsPerDate(selectDate: Date())
    @State var perDayListFlg = false
    @State var selectDay = Date()
    @State var monthSummaryFlg = false
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                let global = $0.frame(in: .global)
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        Header()
                        SelectorTab()
                        VStack(spacing: 15){
                            switch selectListView {
                            case true:
                                ListView()
                            case false:
                                CalendarView(width: global.width - 30, height: size.height)
                            }
                        }
                        .padding(15)
                            .padding(.bottom, 50)
                    }
                }.scrollIndicators(.hidden)
                    .scrollDisabled(selectListView && incConsDic.isEmpty)
            }
            .ignoresSafeArea(.container, edges: .top)
                .navigationDestination(isPresented: $detailPageFlg) {
                    IncConsDetailView(accentColors: accentColors,
                                      detailPageFlg: $detailPageFlg,
                                      incConsObject: $incConsObject,
                                      incConsDic: $incConsDic)
                }.navigationDestination(isPresented: $perDayListFlg) {
                    IncConsListPerDayView(perDayListFlg: $perDayListFlg,
                                          selectDay: $selectDay)
                }
                .navigationDestination(isPresented: $monthSummaryFlg) {
//                    IncConsSummaryView()
                }
        }.onChange(of: selectDate) {
            self.incConsDic = incConsService.getIncConsPerDate(selectDate: selectDate)
        }.alert("収支情報の削除", isPresented: $alertFlg) {
            Button("削除",role: .destructive) {
                withAnimation {
                    incConsService.deleteIncConsData(incConsKey: self.incConsObject.incConsKey)
                    self.incConsDic = incConsService.getIncConsPerDate(selectDate: Date())
                }
            }
            Button("キャンセル", role: .cancel) {
                self.alertFlg = false
            }
        } message: {
            Text("⚠️この収支情報は完全に失われます。\nよろしいですか？")
        }
    }
    
    @ViewBuilder
    func Header() -> some View {
        let year: Int = calendarService.getOnlyComponent(date: selectDate, component: .year)
        let month: Int = calendarService.getOnlyComponent(date: selectDate, component: .month)
        let incTotal: Int = incConsService.getIncOrConsAmtTotal(date: selectDate, incFlg: true)
        let consTotal: Int = incConsService.getIncOrConsAmtTotal(date: selectDate, incFlg: false)
        let totalGap = incTotal + consTotal
        GeometryReader {
            let size = $0.size
            let minY = $0.frame(in: .scrollView).minY
            let maxHeight = size.height - (dateSelectorHeight)
            let progress = max(min((-minY / maxHeight), 1), 0)
            // ▼ 42 = (barSize(1) * 2) + (barPadding(5) * 4) + (rectPadding(20))
            let cardWidth = size.width - 42
            VStack(spacing: 0) {
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
                    Group {
                        Button(action: {
                            withAnimation {
                                self.selectDate = calendarService.previewMonth(date: selectDate)
                            }
                        }) {
                            Image(systemName: "chevron.left")
                        }.padding(.trailing, 20)
                        Button(action: {
                            withAnimation {
                                self.selectDate = calendarService.nextMonth(date: selectDate)
                            }
                        }) {
                            Image(systemName: "chevron.right")
                        }
                        .padding(.vertical, 20)
                    }.fontWeight(.bold)
                }.foregroundStyle(Color.white)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .frame(height: dateSelectorHeight)
                    .padding(.horizontal, 10)
                ZStack(alignment: .bottom) {
                    generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 0)
                    VStack {
                        HStack(spacing: 0) {
                            VStack {
                                Text("\(incTotal)")
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                Text("収入合計")
                                    .font(.caption2.bold())
                            }.frame(width: abs((cardWidth / 3) - 10))
                            generalView.Bar()
                                .frame(height: cardHeight / 2)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                            VStack {
                                Text("\(consTotal)")
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                Text("支出合計")
                                    .font(.caption2.bold())
                            }.frame(width: abs((cardWidth / 3) - 10))
                            generalView.Bar()
                                .frame(height: cardHeight / 2)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                            VStack {
                                Text("\(totalGap)")
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                Text("収支合計")
                                    .font(.caption2.bold())
                            }.frame(width: abs((cardWidth / 3) - 10))
                        }.foregroundStyle(.white)
                        ZStack {
                            Rectangle()
                                .frame(height: cardHeight / 3.5)
                                .foregroundStyle(.changeable)
                            HStack(spacing: 10) {
                                Text("月間情報")
                                Image(systemName: "chevron.right")
                            }.font(.caption2.bold())
                                .foregroundStyle(Color.changeableText)
                                .frame(width: abs(cardWidth - 30), alignment: .trailing)
                        }
                    }
                }.clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(height: cardHeight)
                    .padding(.horizontal, 10)
                    .onTapGesture {
                        self.monthSummaryFlg = true
                    }
            }.padding(.bottom, 20)
            .frame(height: size.height - (maxHeight * progress), alignment: .top)
            .background(
                LinearGradient(colors: accentColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            // headerを固定
            .clipped()
            .offset(y: -minY)
            .contentShape(.rect)
        }.frame(height: dateSelectorHeight + cardHeight + 20)
            .zIndex(1000)
    }
    
    @ViewBuilder
    func SelectorTab() -> some View {
        let rectHeight: CGFloat = 50
        let barHeight: CGFloat = 3
        GeometryReader {
            let minY = $0.frame(in: .scrollView).minY
            HStack(spacing: 0) {
                VStack {
                    if selectListView {
                        Rectangle().fill(accentColors.last!)
                            .frame(height: barHeight)
                    }
                    ZStack {
                        Rectangle()
                            .fill(selectListView ? .changeable : Color(uiColor: .systemGray6))
                            .onTapGesture {
                                withAnimation {
                                    self.selectListView = true
                                }
                            }
                        HStack {
                            Text("収支一覧")
                            Image(systemName: "list.bullet")
                        }.font(.caption.bold())
                            .foregroundStyle(selectListView ? accentColors.last! : Color.changeableText)
                    }
                }
                VStack {
                    if !selectListView {
                        Rectangle().fill(accentColors.last!)
                            .frame(height: barHeight)
                    }
                    ZStack {
                        Rectangle()
                            .fill(!selectListView ? .changeable : Color(uiColor: .systemGray6))
                            .onTapGesture {
                                withAnimation {
                                    self.selectListView = false
                                }
                            }
                        HStack {
                            Text("カレンダー")
                            Image(systemName: "calendar")
                        }.font(.caption.bold())
                            .foregroundStyle(selectListView ? Color.changeableText : accentColors.last!)
                    }
                }
            }.frame(height: rectHeight)
                .background(.changeable)
                .padding(.bottom, 10)
                .offset(y: minY <= 100 ? -(minY - 100) : minY > 220 ? -(minY - 220): 0)
        }.frame(height: rectHeight)
            .zIndex(1000)
    }
    
    @ViewBuilder
    func ListView() -> some View {
        let month: Int = calendarService.getOnlyComponent(date: selectDate, component: .month)
        let labels = [0: "日付　新しい順", 1: "日付　古い順"]
        if incConsDic.isEmpty {
            Text(String(month) + "月の収支情報が存在しません。")
                .font(.caption)
                .foregroundStyle(Color.changeableText)
                .padding(.top, 100)
        } else {
            HStack {
                Spacer()
                Menu {
                    ForEach(labels.sorted(by: {$0.key > $1.key}), id: \.key) { key, value in
                        Button(action: {
                            switch key {
                            case 0:
                                print(key)
                            case 1:
                                print(key)
                            default:
                                print(key)
                            }
                        }) {
                            Text(value)
                        }
                    }
                } label: {
                    HStack {
                        Text("並び替え")
                        Image(systemName: "chevron.up.chevron.down")
                    }.foregroundStyle(accentColors.last ?? .changeableText)
                        .font(.caption.bold())
                }
            }
            ForEach(incConsDic.sorted(by: {$0.key > $1.key}), id: \.key) { key, value in
                let day = incConsService.treatDateText(dateStr: key)
                VStack(alignment: .leading) {
                    HStack {
                        Text(day)
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.changeableText)
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(accentColors.last ?? .changeable)
                            Text(value.count <= 99 ? "\(value.count)" : "99+")
                                .font(.system(.caption2, design: .rounded, weight: .bold))
                                .foregroundStyle(Color.white)
                        }.frame(width: 30)
                            .padding(.leading, 10)
                    }
                    HStack(spacing: 0) {
                        generalView.Bar()
                            .padding(.horizontal, 20)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(value.indices, id: \.self) { index in
                                    let result = value[index]
                                    DetailCard(incConsObject: result,
                                               incFlg: result.incFlg,
                                               incConsAmt: result.incConsAmtTotal,
                                               secKey: result.incConsSecKey,
                                               catgKey: result.incConsCatgKey)
                                }
                            }
                        }.frame(height: 60)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func DetailCard(incConsObject: IncomeConsumeModel, incFlg: Bool, incConsAmt: Int,
                    secKey: String, catgKey: String) -> some View {
        let secResult = try? Realm().object(ofType: IncConsSectionModel.self, forPrimaryKey: secKey)
        let rectWidth: CGFloat = 150
        let iconWH: CGFloat = 40
        let iconPadding: CGFloat = 5
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
            HStack(spacing: 0) {
                if let result = secResult {
                    let catgResult = try! Realm().object(ofType: IncConsCategoryModel.self, forPrimaryKey: catgKey)!
                    let color = ColorAndImage.colors[result.incConsSecColorIndex]
                    let image = result.incConsSecImage
                    let text = catgResult.incConsCatgNm
                    generalView.RoundedIcon(radius: 10, color: color, image: image, text: text)
                        .font(.caption.bold())
                        .frame(width: iconWH, height: iconWH)
                        .padding(iconPadding)
                    VStack(spacing: 10) {
                        HStack {
                            Text(text)
                            Spacer()
                            Menu {
                                Button(action: {
                                    self.detailPageFlg = true
                                    self.incConsObject = incConsObject
                                }) {
                                    HStack {
                                        Text("詳細")
                                        Image(systemName: "chevron.right")
                                    }
                                }
                                Button(role: .destructive,action: {
                                    self.alertFlg = true
                                    self.incConsObject = incConsObject
                                }) {
                                    HStack {
                                        Text("削除")
                                        Image(systemName: "trash")
                                    }
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .rotationEffect(Angle(degrees: 90))
                                    .padding(3)
                            }
                        }.font(.caption)
                            .foregroundStyle(Color.changeableText)
                        Text("¥\(incConsAmt)")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(incFlg ? .blue : .red)
                            .frame(maxWidth: rectWidth - (iconWH + (iconPadding * 2)),
                                   alignment: .trailing)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }.padding(.horizontal, 5)
                        .frame(maxWidth: rectWidth - (iconWH + (iconPadding * 2)))
                } else {
                    let color = ColorAndImage.colors[24]
                    generalView.RoundedIcon(radius: 5, color: color, image: "exclamationmark",
                                            text: "未登録")
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }.frame(width: rectWidth)
    }
    
    @ViewBuilder
    func CalendarView(width: CGFloat, height: CGFloat) -> some View {
        let week = ["月", "火", "水", "木", "金", "土", "日"]
        let dates = calendarService.getDatesOfMonth(date: selectDate)
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(week.indices, id: \.self) { index in
                    let color: Color = index == 5 ? .blue : index == 6 ? .red : .gray
                    Text(week[index])
                        .frame(width: width / 7)
                        .font(.caption2)
                        .foregroundStyle(color)
                }
            }.padding(.bottom, 5)
            ForEach(1 ... 6, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(1 ... 7, id: \.self) { col in
                        let index = col + (row * 7) - 7
                        let date = dates[index - 1]
                        let day = calendarService.getStringDate(date: date, format: "d")
                        let isToday =
                        calendarService.getStringDate(date: date, format: "yyyyMMdd") ==
                        calendarService.getStringDate(date: Date(), format: "yyyyMMdd")
                        let isOffsetDay =
                        calendarService.isDifferentMonth(selectDate: self.selectDate, calendarDate: date)
                        let isSelectDay =
                        calendarService.getStringDate(date: date, format: "yyyyMMdd") ==
                        calendarService.getStringDate(date: self.selectDate, format: "yyyyMMdd")
                        let incAmt = incConsService.getIncConsTotalPerDay(day: date, incFlg: true)
                        let consAmt = incConsService.getIncConsTotalPerDay(day: date, incFlg: false)
                        let isExsistInc = incConsService.isExsistIncConsData(day: date, incFlg: true)
                        let isExsistCons = incConsService.isExsistIncConsData(day: date, incFlg: false)
                        ZStack(alignment: .top) {
                            Rectangle()
                                .foregroundStyle(isSelectDay ? Color(uiColor: .systemGray6) : .clear)
                            VStack(spacing: 3){
                                generalView.Border()
                                    .foregroundStyle(Color(uiColor: .systemGray6))
                                Circle()
                                    .fill(isToday ? accentColors.last ?? .black : .clear)
                                    .frame(width: 17)
                                    .overlay(
                                        Text(day)
                                            .foregroundStyle(
                                                isToday ? .white : isOffsetDay ? .gray : Color.changeableText
                                            )
                                            .font(.system(.caption2, design: .rounded))
                                    )
                                    Group {
                                        Text(isExsistInc ? "¥\(incAmt)" : "")
                                            .foregroundStyle(isOffsetDay ? .gray : .blue)
                                        Text(isExsistCons ? "¥\(consAmt)" : "")
                                            .foregroundStyle(isOffsetDay ? .gray : .red)
                                    }.frame(width: (width / 7) - 5)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .font(.system(.caption2, design: .rounded, weight: .bold))
                            }
                        }.frame(width: width / 7, height: 80)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if (selectDate == date) && (isExsistInc || isExsistCons) {
                                    self.selectDay = date
                                    self.perDayListFlg = true
                                }
                                if !isOffsetDay {
                                    self.selectDate = date
                                }
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    var accentColors: [Color] = [.purple, .indigo]
    return PaymentView(accentColors: accentColors)
}
