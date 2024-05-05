//
//  AnimationHelper.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2023/12/30.
//

import Foundation
import SwiftUI

fileprivate struct AnimationReaderModifier<Body: View>: AnimatableModifier {
    let content: (CGFloat) -> Body
    var animatableData: CGFloat

    init(value: CGFloat, @ViewBuilder content: @escaping (CGFloat) -> Body) {
        self.animatableData = value
        self.content = content
    }

    func body(content: Content) -> Body {
        self.content(animatableData)
    }
}

struct AnimationReader<Content: View>: View {

    let value: CGFloat
    let content: (_ animatingValue: CGFloat) -> Content

    init(_ observedValue: Int, @ViewBuilder content: @escaping (_ animatingValue: Int) -> Content) {
        self.value = CGFloat(observedValue)
        self.content = { value in content(Int(value)) }
    }

    init(_ observedValue: CGFloat, @ViewBuilder content: @escaping (_ animatingValue: CGFloat) -> Content) {
        self.value = observedValue
        self.content = content
    }

    var body: some View {
        EmptyView()
            .modifier(AnimationReaderModifier(value: value, content: content))
    }
}
