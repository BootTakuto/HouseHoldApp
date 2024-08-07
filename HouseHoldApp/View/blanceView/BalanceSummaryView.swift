//
//  BalanceSammaryView.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/01/18.
//

import SwiftUI
import RealmSwift

struct BalanceSummaryView: View {
    var accentColors: [Color]
    @Binding var popUpFlg: Bool
    @Binding var popUpStatus: PopUpStatus
    @Binding var balModel: BalanceModel
    @State var sortType = 0
    // results
    @State var balResults = BalanceService().getBalanceResults()
    /** service */
    let balanceService = BalanceService()
    /** ビュー関連 **/
    let rectHeight: CGFloat = 150
    // 汎用ビュー
    let generalView = GeneralComponentView()
    // チャート
    let charts = FinanceCharts()
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let size =  geometry.size
                let global = geometry.frame(in: .global)
                let maxX = global.maxX
                VStack(spacing: 0) {
                    ZStack(alignment: .bottom) {
                        LinearGradient(colors: accentColors,
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
                        BalanceTotalArea(size: size)
                    }
                    .ignoresSafeArea()
                        .frame(height: 80)
//                    SortMenu()
                    SortTab()
                    ScrollView {
                        VStack(spacing: 0) {
                            BalanceSummaryArea(size: size)
                                .padding(.vertical, 5)
                            SubTitles(size: size)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                            BalanceList(size: size)
                                .padding(.horizontal, 20)
                        }.padding(.bottom, 150)
                            .foregroundStyle(Color.changeableText)
                    }.scrollIndicators(.hidden)
                }
                generalView.glassCircleButton(imageColor: .changeableText, imageNm: "plus") {
                    withAnimation {
                        self.popUpFlg = true
                        self.popUpStatus = .addBalance
                    }
                }.frame(width: 50, height: 50)
                    .shadow(radius: 10)
                    .offset(x: maxX - 70, y: global.height - 140)
            }
        }.onChange(of: sortType) {
            withAnimation {
                switch sortType {
                case 0:
                    self.balResults = balanceService.getBalanceResults()
                case 1:
                    self.balResults = balResults.sorted(byKeyPath: "balanceNm", ascending: true)
                case 2:
                    self.balResults = balResults.sorted(byKeyPath: "balanceNm", ascending: false)
                case 3:
                    self.balResults = balResults.sorted(byKeyPath: "balanceAmt", ascending: true)
                case 4:
                    self.balResults = balResults.sorted(byKeyPath: "balanceAmt", ascending: false)
                default:
                    break
                }
            }
        }
    }
    
    @ViewBuilder
    func BalanceTotalArea(size: CGSize) -> some View{
        let balTotal = balanceService.getBalanceTotal()
        VStack(spacing: 0) {
            Text("残 高 合 計")
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: size.width - 40, alignment: .leading)
            HStack(spacing: 0) {
                Text("¥\(balTotal)")
                    .font(.title)
                    .padding(.top, 5)
                    .padding(.bottom, 10)
                Spacer()
            }.padding(.horizontal, 20)
        }.foregroundStyle(Color.white)
            .fontWeight(.medium)
    }
    
    @ViewBuilder
    func SortMenu() -> some View {
        HStack {
            Spacer()
            Menu {
                
            } label:  {
                RoundedRectangle(cornerRadius: .infinity)
                    .fill(accentColors.last ?? .blue)
                    .frame(width: 100, height: 30)
                    .overlay {
                        HStack {
                            Text("並び替え")
                                .font(.caption)
                            Image(systemName: "chevron.up.chevron.down")
                        }.foregroundStyle(.white)
                    }
            }
        }.padding(.horizontal, 10)
            .padding(.vertical, 5)
    }
    
    @ViewBuilder
    func SortTab() -> some View {
        let texts = ["登録順", "残高・昇順", "残高・降順", "金額・昇順", "金額・降順"]
        ScrollView(.horizontal) {
            HStack {
                ForEach(texts.indices, id: \.self) { index in
                    let isSelectIndex = sortType == index
                    ZStack {
                        if isSelectIndex {
                            RoundedRectangle(cornerRadius: .infinity)
                                .fill(accentColors.last ?? .blue)
                        } else {
                            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: .infinity)
                        }
                        Text(texts[index])
                            .font(.caption)
                            .foregroundStyle(isSelectIndex ? Color.white : Color.changeableText)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            
                    }.onTapGesture {
                        withAnimation {
                            self.sortType = index
                        }
                    }
                }
            }.padding(5)
        }.frame(height: 30)
            .scrollIndicators(.hidden)
            .padding(.horizontal, 10)
            .padding(.vertical, 15)
    }
    
    @ViewBuilder
    func BalanceSummaryArea(size: CGSize) -> some View {
        VStack {
            HStack {
                Text("チャート")
                Image(systemName: "chart.bar.xaxis.ascending")
            }.foregroundStyle(Color.changeableText)
                .font(.caption)
                .fontWeight(.medium)
                .frame(width: size.width - 40, alignment: .leading)
            charts.BalCompareChart(size: size)
                .frame(height: 150)
                .padding(.horizontal, 20)
        }
    }
    
    @ViewBuilder
    func SubTitles(size: CGSize) -> some View {
        let areaWidth = size.width - 40
        VStack {
            HStack {
                Text(LabelsModel.BalListLabel)
                    .padding(.vertical, 12)
                Image(systemName: "list.bullet")
                Spacer()
            }
//            .font(.footnote)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.changeableText)
                .frame(maxWidth: abs(areaWidth))
        }
    }
    
//    @ViewBuilder
//    func BalanceTotalCard(size: CGSize) -> some View {
//        let rectWidth = size.width - 40
//        let balTotal = balanceService.getBalanceTotal()
//        ZStack {
//            generalView.GradientCard(colors: accentColors, radius: 10)
//            VStack(spacing: 0) {
//                HStack {
//                    VStack {
//                        Text("¥\(balTotal)")
////                            .font(.system(.title3, design: .rounded, weight: .bold))
//                            .font(.title3.bold())
//                            .lineLimit(1)
//                            .minimumScaleFactor(0.5)
//                        Text("残 高 合 計")
//                            .font(.subheadline)
//                            .fontWeight(.medium)
//                    }
//                    .foregroundStyle(Color.white)
//                        .frame(maxWidth: abs(rectWidth * (3 / 5)), alignment: .center)
//                        .padding(.vertical, 10)
//                        .padding(.leading, 10)
//                    BalancePieChart()
//                        .frame(width: abs(rectWidth * (2 / 5)))
//                        .padding(10)
//                }
//                ZStack {
//                    generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 0)
//                        .frame(height: rectHeight / 5)
//                    HStack(spacing: 10) {
//                        Text("残高構成")
//                        Image(systemName: "chevron.right")
//                    }.frame(maxWidth: abs(rectWidth - 30), alignment: .trailing)
//                    .font(.caption.bold())
//                    .foregroundStyle(.white)
//                }
//            }
//        }.clipShape(RoundedRectangle(cornerRadius: 10))
//            .shadow(color: .changeableShadow, radius: 5)
//    }
    
//    @ViewBuilder
//    func BalancePieChart() -> some View {
//        ZStack {
//            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
//        }
//    }
    
    @ViewBuilder
    func BalanceDetailCard(size: CGSize, result: BalanceModel) -> some View {
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
            HStack(spacing: 0) {
                Rectangle().fill(ColorAndImage.colors[result.colorIndex]).frame(width: 10)
                VStack {
                    HStack(spacing: 0) {
                        Text(result.balanceNm)
                            .font(.footnote)
                            .foregroundStyle(Color.changeableText)
                            .frame(width: abs((size.width - 60) / 2), alignment: .leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .padding(.horizontal, 10)
                        Spacer()
                    }
                    HStack(spacing: 0) {
                        Spacer()
                        Text("¥\(result.balanceAmt)")
                            .font(.footnote)
                            .foregroundStyle(result.balanceAmt > 0 ? .blue : .red)
                            .frame(width: abs((size.width - 60) / 2), alignment: .trailing)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .padding(.horizontal, 10)
                    }
                }
                .frame(maxWidth: abs(size.width - 40))
            }
        }.frame(height: 70)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    @ViewBuilder
    func BalanceList(size: CGSize) -> some View {
        VStack {
            if balResults.isEmpty {
                VStack {
                    Text("残高が存在しません。")
                        .font(.caption)
                        .foregroundStyle(.gray)
                }.padding(.top, 100)
            } else {
                ForEach(balResults.indices, id: \.self) { index in
                    let result = balResults[index]
                    SwipeActioin(direction: .trailing, content: {
                        BalanceDetailCard(size: size, result: result)
                            .background(Color.changeable)
                    }) {
                        Action(buttonColor: .gray, iconNm: "pencil.line") {
                            withAnimation {
                                self.balModel = result
                                self.popUpFlg = true
                                self.popUpStatus = .editBalance
                            }
                        }
                        Action(buttonColor: .red, iconNm: "trash") {
                            withAnimation {
                                self.balModel = result
                                self.popUpFlg = true
                                self.popUpStatus = .deleteBalance
                            }
                        }
                    }.clipShape(RoundedRectangle(cornerRadius: 10))
                }.padding(.bottom, 5)
            }
        }
    }
}

#Preview {
    @State var popUpFlg = false
    @State var popUpStatus: PopUpStatus = .addBalance
    @State var balModel = BalanceModel()
    return BalanceSummaryView(accentColors: [.yellow, .orange],
                              popUpFlg: $popUpFlg,
                              popUpStatus: $popUpStatus,
                              balModel: $balModel)
}

//#Preview {
//    ContentView()
//}
