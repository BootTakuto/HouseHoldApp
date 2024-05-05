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
    // 残高金額
    @State var asstsbalTotal = BalanceService().getAssDebtBalTotal(assetsFlg: true)
    @State var debtBalTotal = BalanceService().getAssDebtBalTotal(assetsFlg: false)
    // 残高登録情報
    @State var addBalAlertFlg = false
    @State var balanceNm = ""
    // 残高編集
    @State var delBalAlertFlg = false
    @State var balanceKey = ""
    // result
    @ObservedResults(BalanceModel.self, where: {$0.assetsFlg}) var assetsBalResults
    @ObservedResults(BalanceModel.self, where: {!$0.assetsFlg}) var debtBalResults
    // service instance
    let service = BalanceService()
    /** ビュー関連 */
    // 表示切り替えフラグ
    @State var selectAssets = true
    // レイアウト
    let screen = UIScreen.main.bounds
    let headerHeight = UIScreen.main.bounds.height / 20
    let cardHeight: CGFloat = 100
    // 汎用ビュー
    let generalView = GeneralComponentView()
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            ZStack(alignment: .top) {
                ScrollView {
                    VStack {
                        BalanceTotalCard(w: width - 40, h: height / 6,
                                         label: LabelsModel.totalAmtLable,
                                         asstsTotal: asstsbalTotal, debtTotal: debtBalTotal)
                        Text(LabelsModel.kindsOfBalLabel)
                            .font(.caption2)
                            .foregroundStyle(Color.changeableText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                        HStack(spacing: 0) {
                            AssetsDebtCard(w: width / 2 - 30,
                                           h:height / 8,
                                           label: "資 産 残 高", amt: asstsbalTotal,
                                           isSelected: self.selectAssets ? true : false, isAssets: true)
                            .padding(.trailing, 10)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    self.selectAssets = true
                                }
                            }
                            AssetsDebtCard(w: width / 2 - 30,
                                           h: height / 8,
                                           label: LabelsModel.debtTotalAmtlable, amt: debtBalTotal,
                                           isSelected: !self.selectAssets ? true : false, isAssets: false)
                            .padding(.leading, 10)
                            .onTapGesture {
                                withAnimation {
                                    self.selectAssets = false
                                }
                            }
                        }
                        HStack {
                            Text(LabelsModel.BalListLabel)
                                .font(.caption2)
                                .foregroundStyle(Color.changeableText)
                                .padding(.vertical, 12)
                            Spacer()
                            AddBalanceButton(w: width / 5)
                        }.padding(.horizontal, 20)
                            ScrollView {
                                LazyVStack(spacing: 10) {
                                    if self.selectAssets {
                                        if assetsBalResults.isEmpty {
                                            Text("資産残高が存在しません。")
                                                .font(.caption)
                                                .padding(.top, 30)
                                        } else {
                                            ForEach(assetsBalResults, id: \.self) { result in
                                                Menu {
                                                    Button(action: {
                                                        
                                                    }) {
                                                        Label("残高名変更", systemImage: "pencil")
                                                    }
                                                    Button(role: .destructive, action: {
                                                        self.delBalAlertFlg = true
                                                        self.balanceKey = result.balanceKey
                                                    }) {
                                                        Label("削除", systemImage: "trash")
                                                    }
                                                } label: {
                                                    BalanceDetailCard(balNm: result.balanceNm, amt: result.balanceAmt)
                                                        .frame(width: width - 40, height: 80)
                                                }
                                            }
                                        }
                                    } else {
                                        if debtBalResults.isEmpty {
                                            Text("負債残高が存在しません。")
                                                .font(.caption)
                                                .padding(.top, 30)
                                        } else {
                                            ForEach(debtBalResults, id: \.self) { result in
                                                Menu {
                                                    Button(action: {
                                                        
                                                    }) {
                                                        Label("残高名変更", systemImage: "pencil")
                                                    }
                                                    Button(role: .destructive, action: {
                                                        self.delBalAlertFlg = true
                                                        self.balanceKey = result.balanceKey
                                                    }) {
                                                        Label("削除", systemImage: "trash")
                                                    }
                                                } label: {
                                                    BalanceDetailCard(balNm: result.balanceNm, amt: result.balanceAmt)
                                                        .frame(width: width - 40, height: 80)
                                                        .padding(0)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                    }.padding(.top, 60)
                        .padding(.bottom, 80)
                }.scrollIndicators(.hidden)
            }
        }.alert(self.selectAssets ? "資産残高の追加" : "負債残高の追加", isPresented: $addBalAlertFlg) {
            TextField(self.selectAssets ? "銀行名、ICカード名" : "銀行名、クレジット名", text: $balanceNm)
            Button("キャンセル") {
                self.addBalAlertFlg = false
            }
            Button("追加") {
                if balanceNm != "" {
                    service.registBalance(balanceNm: balanceNm, assetsFlg: selectAssets)
                }
            }
        }.alert("削除してよろしいですか。", isPresented: $delBalAlertFlg) {
            Button("削除",role: .destructive) {
                service.deleteBalance(balanceKey: balanceKey)
                self.asstsbalTotal = service.getAssDebtBalTotal(assetsFlg: self.selectAssets)
            }
            Button("キャンセル", role: .cancel) {
                self.delBalAlertFlg = false
            }
        }.onAppear {
            // ▼レンダリングのタイミングで行う必要がない
//            self.asstsbalTotal = service.getAssDebtBalTotal(assetsFlg: true)
//            self.debtBalTotal = service.getAssDebtBalTotal(assetsFlg: false)
        }
    }
    
    @ViewBuilder
    func AddBalanceButton(w: CGFloat) -> some View {
        Button(action: {
            self.addBalAlertFlg = true
            self.balanceNm = ""
        }) {
            ZStack {
                generalView.GradientCard(colors: accentColors, radius: 5)
                    .frame(width: w, height: 25)
                    .shadow(color: .changeableShadow, radius: 1, x: 2, y: 2)
                HStack {
                    Text(LabelsModel.addLabel)
                    Image(systemName: "plus")
                }.foregroundStyle(.white)
                .font(.caption2.bold())
            }
        }
    }
    
    @ViewBuilder
    func AssetsDebtCard(w: CGFloat, h: CGFloat, label: String,
                        amt: Int, isSelected: Bool, isAssets: Bool) -> some View {
        ZStack {
            generalView.GlassBlur(effect: isSelected ? .systemMaterial : .systemUltraThinMaterial, radius: 10)
                    .frame(width: w, height: h)
                    .shadow(color: isSelected ? .changeableShadow : .clear, radius: 3, x: 3, y: 3)
            VStack {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isSelected ? .white : .changeableGlass.opacity(0.3))
                            .shadow(color: .changeableShadow, radius: 2, x: 2, y: 2)
                        Image(systemName: isAssets ? "arrow.up.right" : "arrow.down.right")
                            .foregroundStyle(isAssets ? .blue : .red)
                    }.frame(width: 25, height: 25)
                    Text(label)
                        .font(.caption2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Text("¥\(amt)")
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }.foregroundStyle(Color.changeableText)
                .padding(.horizontal, 30)
        }.frame(width: w, height: h)
    }
    
    @ViewBuilder
    func BalanceDetailCard(balNm: String, amt: Int) -> some View {
        GeometryReader { geometry in
            ZStack {
                generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 5)
                VStack {
                    Text(balNm)
                        .font(.caption2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("¥\(amt)")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }.padding(.horizontal, 30)
                    .foregroundStyle(Color.changeableText)
            }
        }
    }
    
    @ViewBuilder
    func BalanceTotalCard(w: CGFloat, h: CGFloat, label: String, asstsTotal: Int, debtTotal: Int) -> some View {
        ZStack {
            generalView.GradientCard(colors: accentColors, radius: 10)
                .shadow(color: .changeableShadow, radius: 2, x: 4, y: 4)
                .frame(width: w, height: h)
            HStack() {
                VStack(alignment: .leading) {
                    Text(label)
                        .font(.caption.bold())
                    Text("¥ \(asstsTotal - debtTotal)")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    Text("¥ \(asstsTotal)")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                    Text("¥ \(debtTotal)")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                }.foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                BalancePieChart(w: w, h: h,
                                assetRate: 1.0, netRate: 0.8, debtRate: 0.2)
            }.padding(.horizontal, 40)
        }
    }
    
    @ViewBuilder
    func BalancePieChart(w: CGFloat, h: CGFloat,
                         assetRate: Double, netRate: Double, debtRate: Double) -> some View {
            ZStack {
                UIGlassCard(effect: .systemUltraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(color: Color(uiColor: .darkGray), radius: 2, x: 2, y: 2)
                HStack(alignment: .top) {
                    VStack(spacing: 3) {
                        ZStack(alignment: .bottom) {
                            HStack(spacing: 3) {
                                Text("\(asstsbalTotal - debtBalTotal)")
                                    .font(.system(size: 5))
                                generalView.Border()
                                    .frame(width: 5)
                            }.frame(width: w / 12, height: (h / 1.5) * netRate,
                                    alignment: .topTrailing)
                            HStack(spacing: 3) {
                                Text("\(asstsbalTotal)")
                                    .font(.system(size: 5))
                                generalView.Border()
                                    .frame(width: 5)
                            }.frame(width: w / 12, height: (h / 1.5) * assetRate,
                                    alignment: .topTrailing)
                            HStack(spacing: 3) {
                                Text("\(debtBalTotal)")
                                    .font(.system(size: 5))
                                generalView.Border()
                                    .frame(width: 5)
                            }.frame(width: w / 12, height: (h / 1.5) * debtRate,
                                    alignment: .topTrailing)
                        }.frame(maxHeight: h / 1.5)
                    }
                    Group {
                        VStack(spacing: 3) {
                            UIGlassCard(effect: .systemMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .frame(width: w / 12, height: (h / 1.5) * netRate)
                            Text("純資産")
                                .font(.system(size: 5).bold())
                        }
                        VStack(spacing: 3) {
                            UIGlassCard(effect: .systemMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .frame(width: w / 12, height: (h / 1.5) * assetRate)
                            Text("資産")
                                .font(.system(size: 5).bold())
                        }
                        VStack(spacing: 3) {
                            UIGlassCard(effect: .systemMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .frame(width: w / 12, height: (h / 1.5) * debtRate)
                            Text("負債")
                                .font(.system(size: 5).bold())
                        }
                    }.frame(maxHeight: h / 1.5, alignment: .bottom)
                }.foregroundStyle(Color.changeableGlassStroke)
                    .padding(.bottom, 5)
                    .padding(.top, 15)
            }.frame(width: w / 2 - 15, height: h - 30)
    }
    
    @ViewBuilder
    func ChartLabel(w: CGFloat, colors: [Color], text: String) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(
                    .linearGradient(colors: colors,
                                    startPoint: .topLeading, endPoint: .bottomTrailing)
                ).frame(width: w)
            Text(text)
                .foregroundStyle(Color.changeableText)
                .font(.caption2.bold())
        }
    }
}

#Preview {
    @State var balAmtTotal = 0
    return BalanceSummaryView(accentColors: GradientAccentcColors.gradients[0])
}

//#Preview {
//    ContentView()
//}
