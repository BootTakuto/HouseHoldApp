//
//  ViewExtension.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/05/06.
//

import SwiftUI

extension View  {
    func custumFullScreenCover<Content>(isPresented: Binding<Bool>, transition: AnyTransition, @ViewBuilder content: @escaping () -> Content) -> some View where Content: View {
        ZStack {
            self
            if isPresented.wrappedValue {
                content().zIndex(1000)
            }
        }
    }
}
#Preview {
    ContentView()
}
