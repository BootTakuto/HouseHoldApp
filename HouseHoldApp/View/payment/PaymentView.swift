//
//  PaymentView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/04/09.
//

import SwiftUI
import RealmSwift

struct PaymentView: View {
    /** 表示関連 */
    var accentColors: [Color]
    @State private var selectDate = Date()      // 選択日付
    @State private var selectListView = true    // 収支一覧画面かカレンダー画面か
    @State private var alertFlg = false         // 削除時アラートフラグ
    @State private var incConsListType = 0      // 収支情報の表示タイプ
    @State private var dispFlgs: [Bool] =
    IncomeConsumeService().getIncConsDispFlgs(selectDate: Date(),
    listType: 0) // 収支一覧　日付別の表示フラグ配列
    // 遷移情報
    @State var detailPageFlg = false
    @State var incConsObject = IncomeConsumeModel()
    @State var incConsDic = 
    IncomeConsumeService().getIncConsPerDate(selectDate: Date(), listType: 0)
    @State var perDayListFlg = false                                // カレンダー　→ 収支一覧
    @State var selectDay = Date()                                   // 選択日
    @State var monthSummaryFlg = false                              // 月間情報の詳細ページフラグ
    // service
    let incConsService = IncomeConsumeService()
    let calendarService = CalendarService()
    let incConsSecCatgService = IncConSecCatgService()
    let commonService = CommonService()
    // view設定
    let generalView = GeneralComponentView()                        // 汎用ビュー
    let dateSelectorHeight: CGFloat = 100
    let cardHeight: CGFloat = 100
    var body: some View {
        NavigationStack {
            GeometryReader {
                let size = $0.size
                let global = $0.frame(in: .global)
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        Header()
                        SelectorTab()
                        VStack(spacing: 10){
                            switch selectListView {
                            case true:
                                ListView()
                            case false:
                                CalendarView(width: global.width - 30, height: size.height)
                            }
                        }.padding(15)
                            .padding(.bottom, 100)
                    }
                }.scrollIndicators(.hidden)
                    .scrollDisabled(selectListView && incConsDic.isEmpty)
            }.ignoresSafeArea(.container, edges: .top)
                .navigationDestination(isPresented: $detailPageFlg) {
                    let isLinkBal = !incConsObject.balLinkAmtList.isEmpty
                    let balKeyArray = incConsService.getLinkBalKeyArray(incConsObj: incConsObject)
                    let linkBalAmtArray = incConsService.getLinkBalAmtArrayForView(incConsObj: incConsObject)
                    let selectDate = commonService.convertStrToDate(dateStr: incConsObject.incConsDate,
                                                                    format: "yyyyMMdd")
                    RegistIncConsFormView(registIncConsFlg: $detailPageFlg,
                                          accentColors: accentColors,
                                          isEdit: true,
                                          selectForm: incConsObject.houseHoldType,
                                          linkBalFlg: isLinkBal,
                                          balKeyArray: balKeyArray,
                                          linkBalAmtArray: linkBalAmtArray,
                                          incConsSecKey: incConsObject.incConsSecKey,
                                          incConsCatgKey: incConsObject.incConsCatgKey,
                                          selectDate: selectDate,
                                          memo: incConsObject.memo)
                    .navigationBarBackButtonHidden()
                }.navigationDestination(isPresented: $perDayListFlg) {
                    IncConsListPerDayView(perDayListFlg: $perDayListFlg,
                                          selectDay: $selectDay)
                }.navigationDestination(isPresented: $monthSummaryFlg) {
                    IncConsSummaryView(accentColors: accentColors,
                                       isPresentedFlg: $monthSummaryFlg,
                                       chartIndex: 0,
                                       selectDate: selectDate)
                }.onChange(of: selectDate) {
                    withAnimation {
                        self.incConsDic = incConsService.getIncConsPerDate(selectDate: selectDate,
                                                                           listType: incConsListType)
                        self.dispFlgs = incConsService.getIncConsDispFlgs(selectDate: selectDate,
                                                                          listType: incConsListType)
                    }
                }.onChange(of: incConsListType) {
                    withAnimation {
                        self.incConsDic = incConsService.getIncConsPerDate(selectDate: selectDate,
                                                                           listType: incConsListType)
                        self.dispFlgs = incConsService.getIncConsDispFlgs(selectDate: selectDate,
                                                                          listType: incConsListType)
                    }
                }.alert("収支情報の削除", isPresented: $alertFlg) {
                    Button("削除",role: .destructive) {
                        withAnimation {
                            incConsService.deleteIncConsData(incConsKey: self.incConsObject.incConsKey)
                            self.incConsDic = incConsService.getIncConsPerDate(selectDate: Date(),
                                                                               listType: incConsListType)
                        }
                    }
                    Button("キャンセル", role: .cancel) {
                        self.alertFlg = false
                    }
                } message: {
                    Text("⚠️この収支情報は完全に失われます。\nよろしいですか？")
                }
        }
    }
    
    @ViewBuilder
    func Header() -> some View {
        let year: Int = calendarService.getOnlyComponent(date: selectDate, component: .year)
        let month: Int = calendarService.getOnlyComponent(date: selectDate, component: .month)
        let incTotal: Int = incConsService.getIncOrConsAmtTotal(date: selectDate, houseHoldType: 0)
        let consTotal: Int = incConsService.getIncOrConsAmtTotal(date: selectDate, houseHoldType: 1)
        let totalGap = incTotal - consTotal
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
                                Text("¥\(incTotal)")
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
                                Text("¥\(consTotal)")
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
                                Text("¥\(totalGap)")
                                    .font(.system(.body, design: .rounded, weight: .bold))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                Text("収支合計")
                                    .font(.caption2.bold())
                            }.frame(width: abs((cardWidth / 3) - 10))
                        }.foregroundStyle(.white)
                        ZStack {
                            Rectangle()
                                .frame(height: cardHeight / 5)
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
                            .foregroundStyle(Color.changeableText)
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
                            .foregroundStyle(Color.changeableText)
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
    func DetailCard(result: IncomeConsumeModel, houseHoldType: Int, incConsAmt: Int,
                    secKey: String, catgKey: String) -> some View {
        let secResult = incConsSecCatgService.getIncConsSecSingle(secKey: secKey)
        let symbol = incConsService.getAmountSymbol(result: result)
        let rectWidth: CGFloat = 300
        let iconWH: CGFloat = 40
        let iconPadding: CGFloat = 5
        HStack(spacing: 0) {
            let catgResult = incConsSecCatgService.getIncConsCatgSingle(catgKey: catgKey)
            let color = result.houseHoldType == 2 ?
            Color(uiColor: .systemGray3) : ColorAndImage.colors[secResult.incConsSecColorIndex]
            let image = secResult.incConsSecImage
            let text = catgResult.incConsCatgNm
            generalView.RoundedIcon(radius: 8, color: color, image: image, text: text)
                .frame(width: iconWH, height: iconWH)
                .padding(iconPadding)
            VStack(spacing: 10) {
                HStack {
                    Text(text)
                    Spacer()
                    Menu {
                        Button(action: {
                            self.detailPageFlg = true
                            self.incConsObject = result
                        }) {
                            HStack {
                                Text("詳細")
                                Image(systemName: "chevron.right")
                            }
                        }
                        Button(role: .destructive,action: {
                            self.alertFlg = true
                            self.incConsObject = result
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
                Text(symbol + "\(incConsAmt)")
                    .font(.caption).fontDesign(.rounded)
                    .fontWeight(result.houseHoldType != 2 ? .bold : .regular) 
                    .foregroundStyle(result.houseHoldType == 2 ? Color.changeableText : result.houseHoldType == 1 ?
                        .red : .blue)
                    .frame(maxWidth: rectWidth - (iconWH + (iconPadding * 2)),
                           alignment: .trailing)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }.padding(.horizontal, 5)
                .frame(maxWidth: rectWidth - (iconWH + (iconPadding * 2)))
        }.frame(maxWidth: rectWidth, alignment: .leading)
    }
    
    @ViewBuilder
    func ListView() -> some View {
//        let month: Int = calendarService.getOnlyComponent(date: selectDate, component: .month)
        let labels = ["すべて", "残高操作を除く", "収入", "支出", "残高操作"]
        ScrollView(.horizontal) {
            HStack(spacing: 0) {
                ForEach(labels.indices, id: \.self) { index in
                    let isSelectType = self.incConsListType == index
                    ZStack {
                        if !isSelectType {
                            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 6)
                        } else {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color(uiColor: .systemGray2))
                        }
                        Text(labels[index])
                            .font(.caption.bold())
                            .foregroundStyle(isSelectType ? .white :  Color.changeableText)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                    }.padding(.trailing, 10)
                    .onTapGesture {
                        withAnimation {
                            self.incConsListType = index
                        }
                    }
                }
            }.padding(5)
        }.frame(height: 30)
            .padding(.vertical, 5)
            .padding(.bottom, 10)
        if incConsDic.isEmpty {
            Text("収支情報が存在しません。")
                .font(.caption)
                .foregroundStyle(Color.changeableText)
                .padding(.top, 100)
        } else {
            ForEach(Array(incConsDic.sorted(by: {$0.key > $1.key})).indices, id: \.self) { index in
                let key = Array(incConsDic.sorted(by: {$0.key > $1.key}))[index].key
                let value = incConsDic[key]!
                let day = incConsService.treatDateText(dateStr: key)
                VStack {
                    HStack {
                        Text(day)
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.changeableText)
                            .padding(.vertical, 5)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.subheadline.bold())
                            .rotationEffect(.degrees(self.dispFlgs[index] ? 0 : 180))
                            .foregroundStyle(Color.changeableText)
                            .onTapGesture {
                                withAnimation {
                                    self.dispFlgs[index].toggle()
                                }
                            }
                    }.frame(maxWidth: .infinity, alignment: .leading)
                    HStack(spacing: 0) {
                        if dispFlgs[index] {
                            generalView.Bar()
                                .padding(.horizontal, 15)
                                .foregroundStyle(Color.changeableText)
                            ZStack {
                                generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                                VStack(spacing: 2) {
                                    ForEach(value.indices, id: \.self) { index in
                                        let result = value[index]
                                        DetailCard(result: result,
                                                   houseHoldType: result.houseHoldType,
                                                   incConsAmt: result.incConsAmtValue,
                                                   secKey: result.incConsSecKey,
                                                   catgKey: result.incConsCatgKey)
                                        if value.count - 1 != index {
                                            generalView.Border()
                                                .foregroundStyle(Color(uiColor: .systemGray3))
                                                .padding(5)
                                                .padding(.horizontal, 5)
                                        }
                                    }
                                }.padding(.vertical, 10)
                            }
                        }
                    }
                }
            }
        }
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
                        let incAmt = incConsService.getIncConsTotalPerDay(day: date, houseHoldType: 0)
                        let consAmt = incConsService.getIncConsTotalPerDay(day: date, houseHoldType: 1)
                        let isExsistInc = incConsService.isExsistIncConsData(day: date, houseHoldType: 0)
                        let isExsistCons = incConsService.isExsistIncConsData(day: date, houseHoldType: 1)
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
                                                isToday ? .white : isOffsetDay ?
                                                Color(uiColor: .systemGray3) : Color.changeableText
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
                                        .font(.caption2)
                                        .fontDesign(.rounded)
                                        .fontWeight(isOffsetDay ? .regular : .bold)
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
    PaymentView(accentColors: [.orange, .pink])
}


