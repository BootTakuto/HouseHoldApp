//
//  PagingIndicator.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/06/27.
//

import SwiftUI

struct PagingIndicator: View {
    var activeTint: Color
    var inActiveTint: Color
    var body: some View {
        GeometryReader {
            let width = $0.size.width
            if let scrollViewWidth = $0.bounds(of: .scrollView(axis: .horizontal))?.width,
               scrollViewWidth > 0 {
                let minX = $0.frame(in: .scrollView(axis: .horizontal)).minX
                let totalPages = Int(width / scrollViewWidth)
                // progress
                let progress = -minX / scrollViewWidth
                let activeIndex =  Int(progress + 0.5)
                HStack {
                    ForEach(0 ..< totalPages, id: \.self) { index in
                        let isActive = activeIndex == index
                        Circle()
                            .fill(isActive ? activeTint : inActiveTint)
                            .frame(width: 8, height: 8)
                    }
                }
                .frame(width: scrollViewWidth)
                    .offset(x: -minX)
            }
        }
    }
}

#Preview {
    ContentView()
}
