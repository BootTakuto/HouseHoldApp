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
    /** 表示 */
    @State var isEditMode = false           // 編集モードフラグ
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
            GeometryReader {
                let size =  $0.size
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
                            .padding(.bottom, 100)
                    }
                }.scrollIndicators(.hidden)
            }.onChange(of: popUpFlg) {
                if !popUpFlg {
                    withAnimation {
                        self.isEditMode = false
                    }
                }
            }.onDisappear {
                self.isEditMode = false
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
                if !balResults.isEmpty {
                    if isEditMode {
                        Button(action: {
                            withAnimation {
                                self.isEditMode.toggle()
                            }
                        }) {
                            Text("完了")
                                .font(.caption.bold())
                                .foregroundStyle(accentColors.last ?? .blue)
                        }
                    } else {
                        generalView.glassTextRounedButton(color: accentColors.last ?? .blue, text: "編集", imageNm: "", radius: 25) {
                            withAnimation {
                                self.isEditMode.toggle()
                            }
                        }.frame(width: 80, height: 20)
                            .compositingGroup()
                            .shadow(color: .changeableShadow, radius: 3)
                    }
                }
            }.font(.caption.bold())
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
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text("残 高 合 計")
                            .font(.caption.bold())
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
    func BalanceList(size: CGSize) -> some View {
        VStack {
            if balResults.isEmpty {
                VStack {
                    Text("残高が存在しません。")
                        .font(.caption.bold())
                        .foregroundStyle(Color.changeableText)
                }.padding(.top, 50)
            } else {
                ForEach(balResults.indices, id: \.self) { index in
                    let result = balResults[index]
                    ZStack {
                        generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
                        HStack(spacing: 0) {
                            Rectangle().fill(ColorAndImage.colors[result.colorIndex]).frame(width: 10)
                            VStack {
                                Text(result.balanceNm)
                                    .font(.caption.bold())
                                    .foregroundStyle(Color.changeableText)
                                    .frame(width: isEditMode ? abs(size.width - 200) : abs(size.width - 100),
                                           alignment: .leading)
                                Text("¥\(result.balanceAmt)")
                                    .fontDesign(.rounded)
                                    .fontWeight(.bold)
                                    .foregroundStyle(result.balanceAmt > 0 ? .blue : .red)
                                    .frame(width: isEditMode ? abs(size.width - 200) : abs(size.width - 100),
                                           alignment: .trailing)
                            }
                            .frame(maxWidth: isEditMode ? abs(size.width - 140) : abs(size.width - 40))
                            if isEditMode {
                                Button(action: {
                                    withAnimation {
                                        self.balModel = result
                                        self.popUpFlg = true
                                        self.popUpStatus = .editBalance
                                    }
                                }) {
                                    ZStack {
                                        Rectangle().fill(.gray).frame(width: 50)
                                        VStack {
                                            Image(systemName: "pencil")
                                            Text("変更")
                                                .font(.caption.bold())
                                        }.foregroundStyle(.white)
                                    }
                                }
                                Button(action: {
                                    withAnimation {
                                        self.balModel = result
                                        self.popUpFlg = true
                                        self.popUpStatus = .deleteBalance
                                    }
                                }) {
                                    ZStack {
                                        Rectangle().fill(.red).frame(width: 50)
                                        VStack {
                                            Image(systemName: "trash")
                                            Text("削除")
                                                .font(.caption.bold())
                                        }.foregroundStyle(.white)
                                    }
                                }
                            }
                        }
                    }.frame(height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            if balResults.isEmpty {
                generalView.glassTextRounedButton(color: accentColors.last ?? .blue,
                                                  text: "追加", imageNm: "plus", radius: 25)
                {
                    withAnimation {
                        self.popUpFlg = true
                        self.popUpStatus = .addBalance
                    }
                }.frame(width: 100, height: 30)
                    .compositingGroup()
                    .shadow(color: .changeableShadow, radius: 3)
            } else {
                generalView.glassCircleButton(imageColor: accentColors.last ?? .blue, imageNm: "plus") {
                    withAnimation {
                        self.popUpFlg = true
                        self.popUpStatus = .addBalance
                    }
                }.frame(width: 40, height:  40)
                    .compositingGroup()
                    .shadow(color: .changeableShadow, radius: 3)
                    .padding(.vertical, 5)
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
