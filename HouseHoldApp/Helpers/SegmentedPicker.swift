//
//  SegmentedPicker.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/07/26.
//

import SwiftUI

struct SegmentedPicker: View {
    @Binding var selection: Int
    @State var texts: [String]
    var defaultTextColor: Color
    var selectTextColor: Color
    var backColor: Color
    var selectRectColor: Color
    @State var offset: CGFloat = 5
    var body: some View {
        GeometryReader {
            let size = $0.size
            let areaWidth = CGFloat(Int(size.width) / texts.count)
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(backColor)
                    .frame(height: size.height)
                GeometryReader { geome in
                    RoundedRectangle(cornerRadius: 3)
                        .fill(selectRectColor)
                        .frame(width: areaWidth - 10, height: size.height - 10)
                        .offset(x: offset, y: 5)
                }
                HStack(spacing: 0) {
                    ForEach(texts.indices, id: \.self) { index in
                        let isSelect = index == selection
                        Text(texts[index])
                            .font(.footnote)
                            .foregroundStyle(isSelect ? selectTextColor : defaultTextColor)
                            .frame(width: areaWidth)
                            .onTapGesture {
                                withAnimation {
                                    self.selection = index
                                    self.offset = 5 + areaWidth * CGFloat(index)
                                }
                            }
                    }
                }
            }
        }.frame(height: 30)
    }
}

#Preview {
    @State var selection = 0
    return SegmentedPicker(selection: $selection,
                           texts: ["a", "b", "c", "d"],
                           defaultTextColor: .blue,
                           selectTextColor: .white,
                           backColor: .blue.opacity(0.25),
                           selectRectColor: .blue)
}
