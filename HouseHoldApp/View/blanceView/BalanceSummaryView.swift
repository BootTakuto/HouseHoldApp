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
    // results
    let balResults = BalanceService().getBalanceResults()
    // 表示
    @State var addBalAlertFlg = false
    @State var deleteBalAlertFlg = false
    @FocusState var addBalNmTF
    @FocusState var addBalInitAmountTF
    @State var isEditMode = false
    // 登録情報
    @State var balNm = ""
    @State var initBalAmount = "0"
    @State var colorIndex = 0
    // 変更・削除情報
    @State var balKey = ""
    // service
    let balanceService = BalanceService()
    /** ビュー関連 **/
    // レイアウト
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
                    }.padding(.bottom, 80)
                }.scrollIndicators(.hidden)
            }.custumFullScreenCover(isPresented: $addBalAlertFlg, transition: .opacity) {
                AddBalanceFormAlert()
            }.custumFullScreenCover(isPresented: $deleteBalAlertFlg, transition: .opacity) {
                DeleteBalanceAlert()
            }.onDisappear {
                self.isEditMode = false
                self.addBalAlertFlg = false
                self.deleteBalAlertFlg = false
            }.toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Button(action: {
                            if addBalNmTF {
                                self.balNm = ""
                                self.addBalNmTF = false
                            } else if addBalInitAmountTF {
                                self.initBalAmount = "0"
                                self.addBalInitAmountTF = false
                            }
                        }) {
                            Text("キャンセル")
                        }
                        Spacer()
                        Button(action: {
                            if addBalNmTF {
                                self.addBalNmTF = false
                            } else if addBalInitAmountTF {
                                if self.initBalAmount == "" {
                                    self.initBalAmount = "0"
                                }
                                self.addBalInitAmountTF = false
                            }
                        }) {
                            Text("完了")
                        }
                    }
                }
            }.onChange(of: addBalInitAmountTF) {
                if addBalInitAmountTF && self.initBalAmount == "0" {
                    self.initBalAmount = ""
                }
            }
        }
    }
    
    @ViewBuilder
    func AddBalanceFormAlert() -> some View {
        let rectWidth: CGFloat = 300
        let rectHeight: CGFloat = 200
        ZStack {
            Color.black.opacity(0.25)
            ZStack {
                Color.changeable
                VStack {
                    VStack {
                        Text(isEditMode ? "残高変更" : "残高登録")
                            .fontWeight(.bold)
                        HStack(spacing: 0) {
                            Text("残高名(必須)")
                                .font(.caption2.bold())
                                .frame(width: rectWidth / 3, alignment: .leading)
                            TextField("銀行名、ポイント名など", text: $balNm)
                                .focused($addBalNmTF)
                                .padding(5)
                                .background(Color(uiColor: .systemGray5))
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .font(.caption.bold())
                                .frame(width: rectWidth * (2 / 3))
                        }
                        if !isEditMode {
                            HStack(spacing: 0) {
                                Text("金額初期設定")
                                    .font(.caption2.bold())
                                    .frame(width: rectWidth / 3, alignment: .leading)
                                TextField("", text: $initBalAmount)
                                    .focused($addBalInitAmountTF)
                                    .padding(5)
                                    .background(Color(uiColor: .systemGray5))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .multilineTextAlignment(.trailing)
                                    .font(.caption.bold())
                                    .frame(width: rectWidth * (2 / 3))
                                    .keyboardType(.numberPad)
                            }
                        }
                        HStack(spacing: 0) {
                            Text("識別カラー")
                                .font(.caption2.bold())
                                .frame(width: rectWidth / 3, alignment: .leading)
                            ScrollView(.horizontal) {
                                ScrollViewReader { proxy in
                                    HStack {
                                        ForEach(ColorAndImage.colors.indices, id: \.self) {index in
                                            let color = ColorAndImage.colors[index]
                                            Button(action: {
                                                self.colorIndex = index
                                            }) {
                                                ZStack {
                                                    Circle()
                                                        .fill(color)
                                                        .frame(width: 30)
                                                    if self.colorIndex == index {
                                                        Circle()
                                                            .stroke(lineWidth: 3)
                                                            .fill(.changeable)
                                                            .frame(width: 20)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }.frame(width: rectWidth * (2 / 3))
                                .scrollIndicators(.hidden)
                                .id(self.colorIndex)
                        }
                    }.frame(height: rectHeight - 40)
                        .padding(.horizontal, 15)
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation {
                                self.addBalAlertFlg = false
                                self.balNm = ""
                                self.initBalAmount = "0"
                                self.colorIndex = 0
                            }
                        }) {
                            ZStack {
                                accentColors.last ?? .black
                                Text(isEditMode ? "キャンセル" : "閉じる")
                            }
                        }
                        generalView.Bar()
                            .foregroundStyle(.changeable)
                        Button(action: {
                            withAnimation {
                                if isEditMode {
                                    balanceService.updateBalance(balKey: balKey, balNm: balNm,
                                                                 colorIndex: colorIndex)
                                } else {
                                    balanceService.registBalance(balanceNm: balNm, assetsFlg: true,
                                                                 balAmt: Int(initBalAmount) ?? 0, colorIndex: colorIndex)
                                }
                                self.addBalAlertFlg = false
                                self.balNm = ""
                                self.initBalAmount = "0"
                                self.colorIndex = 0
                            }
                        }) {
                            ZStack {
                                accentColors.last ?? .black
                                Text(isEditMode ? "変更" : "保存")
                            }
                        }
                    }.frame(height: 40)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }.foregroundStyle(Color.changeableText)

            }.clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(y: addBalNmTF ? -40 : addBalInitAmountTF ? -30 : 0)
                .animation(.linear, value: addBalNmTF)
                .animation(.linear, value: addBalInitAmountTF)
            .frame(width: rectWidth, height: rectHeight)
        }.ignoresSafeArea()
    }
    
    @ViewBuilder
    func DeleteBalanceAlert() -> some View {
        let rectWidth: CGFloat = 300
        let rectHeight: CGFloat = 150
        ZStack {
            Color.black.opacity(0.25)
            ZStack {
                Color.changeable
                VStack {
                    VStack {
                        Text("残高削除")
                            .fontWeight(.bold)
                        Text("残高を削除してよろしいですか。")
                            .font(.caption.bold())
                    }.frame(height: rectHeight - 40)
                    HStack(spacing: 0) {
                        Button(action: {
                            withAnimation {
                                self.deleteBalAlertFlg = false
                            }
                        }) {
                            ZStack {
                                accentColors.last ?? .black
                                Text("キャンセル")
                            }
                        }
                        generalView.Bar()
                            .foregroundStyle(.changeable)
                        Button(action: {
                            withAnimation {
                                balanceService.deleteBalance(balanceKey: balKey)
                                self.deleteBalAlertFlg = false
                            }
                        }) {
                            ZStack {
                                Color.red
                                Text("削除")
                            }
                        }
                    }.frame(height: 40)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }.foregroundStyle(Color.changeableText)
            }.frame(width: rectWidth, height: rectHeight)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }.ignoresSafeArea()
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
                    Button(action: {
                        withAnimation {
                            self.isEditMode.toggle()
                        }
                    }) {
                        ZStack {
                            if !isEditMode {
                                generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 25)
                                    .shadow(color: .changeableShadow, radius: 3)
                            }
                            Text(isEditMode ? "完了" : "編集")
                                .foregroundStyle(accentColors.last ?? .changeableText)
                        }
                    }.frame(width: 80, height: 25)
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
//            generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 10)
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
            charts.BalRateChart(assetsFlg: true)
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
                                    .frame(width: isEditMode ? size.width - 200 : size.width - 100,
                                           alignment: .leading)
                                Text("¥\(result.balanceAmt)")
                                    .fontDesign(.rounded)
                                    .fontWeight(.bold)
                                    .foregroundStyle(result.balanceAmt > 0 ? .blue : .red)
                                    .frame(width: isEditMode ? size.width - 200 : size.width - 100,
                                           alignment: .trailing)
                            }
                            .frame(maxWidth: isEditMode ? size.width - 140 : size.width - 40)
                            if isEditMode {
                                Button(action: {
                                    withAnimation {
                                        self.balKey = result.balanceKey
                                        self.balNm = result.balanceNm
                                        self.colorIndex = result.colorIndex
                                        self.addBalAlertFlg = true
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
                                        self.balKey = result.balanceKey
                                        self.deleteBalAlertFlg = true
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
            Button(action: {
                withAnimation {
                    self.addBalAlertFlg = true
                }
            }) {
                if balResults.isEmpty {
                    ZStack {
                        generalView.GlassBlur(effect: .systemUltraThinMaterial, radius: 25)
                            .shadow(color: .changeableShadow, radius: 3)
                        HStack {
                            Text("追加")
                            Image(systemName: "plus")
                        }.font(.caption.bold())
                            .foregroundStyle(accentColors.last ?? .changeableText)
                    }.frame(width: 100, height: 30)
                } else {
                    ZStack {
                        UIGlassCard(effect: .systemUltraThinMaterial)
                            .clipShape(Circle())
                            .frame(width: 40, height: 40)
                            .shadow(color: .changeableShadow, radius: 3)
                        Image(systemName: "plus")
                            .fontWeight(.bold)
                            .foregroundStyle(accentColors.last ?? .changeableText)
                    }.padding(.top, 10)
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
