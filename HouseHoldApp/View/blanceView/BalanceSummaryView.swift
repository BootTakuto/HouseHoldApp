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
    // results
    let balResults = BalanceService().getBalanceResults()
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
                ScrollView {
                    VStack(spacing: 0) {
                        BalanceTotalCard(size: size)
                            .frame(height: rectHeight)
                            .padding(.horizontal, 20)
                        SubTitles(size: size)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                        BalanceList(size: size)
                            .padding(.horizontal, 20)
                    }.padding(.bottom, 150)
                }.scrollIndicators(.hidden)
                generalView.glassCircleButton(imageColor: .changeableText, imageNm: "plus") {
                    withAnimation {
                        self.popUpFlg = true
                        self.popUpStatus = .addBalance
                    }
                }.frame(width: 50, height: 50)
                .shadow(radius: 10)
                .offset(x: maxX - 70, y: global.height - 150)
            }
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
            }.font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.changeableText)
                .frame(maxWidth: abs(areaWidth))
        }
    }
    
    @ViewBuilder
    func BalanceTotalCard(size: CGSize) -> some View {
        let rectWidth = size.width - 40
        let balTotal = balanceService.getBalanceTotal()
        ZStack {
            generalView.GradientCard(colors: accentColors, radius: 10)
            VStack(spacing: 0) {
                HStack {
                    VStack {
                        Text("¥\(balTotal)")
//                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .font(.title3.bold())
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text("残 高 合 計")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(Color.white)
                        .frame(maxWidth: abs(rectWidth * (3 / 5)), alignment: .center)
                        .padding(.vertical, 10)
                        .padding(.leading, 10)
                    BalancePieChart()
                        .frame(width: abs(rectWidth * (2 / 5)))
                        .padding(10)
                }
                ZStack {
                    generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 0)
                        .frame(height: rectHeight / 5)
                    HStack(spacing: 10) {
                        Text("残高構成")
                        Image(systemName: "chevron.right")
                    }.frame(maxWidth: abs(rectWidth - 30), alignment: .trailing)
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                }
            }
        }.clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: .changeableShadow, radius: 5)
    }
    
    @ViewBuilder
    func BalancePieChart() -> some View {
        ZStack {
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
        }
    }
    
    @ViewBuilder
    func BalanceDetailCard(size: CGSize, result: BalanceModel) -> some View {
        ZStack {
            Color.changeable
            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
            HStack(spacing: 0) {
                Rectangle().fill(ColorAndImage.colors[result.colorIndex]).frame(width: 10)
                VStack {
                    Text(result.balanceNm)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.changeableText)
                        .frame(width: abs(size.width - 100),
                               alignment: .leading)
                    Text("¥\(result.balanceAmt)")
                        .font(.headline)
//                        .fontDesign(.rounded)
                        .fontWeight(.bold)
                        .foregroundStyle(result.balanceAmt > 0 ? .blue : .red)
                        .frame(width: abs(size.width - 100),
                               alignment: .trailing)
                }
                .frame(maxWidth: abs(size.width - 40))
            }
        }.frame(height: 80)
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
                }
            }
        }
    }
}

//#Preview {
//    @State var addBalScreenFlg = false
//    return BalanceSummaryView(accentColors: GradientAccentcColors.gradients[0],
//                              addBalScreenFlg: $addBalScreenFlg)
//}

#Preview {
    ContentView()
}
