//
//  SwipeActioin.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2024/06/13.
//

import SwiftUI

struct SwipeActioin<Content: View>: View {
    var direction: Alignment = .trailing
    @State var scrollMinX: CGFloat = 0
    @ViewBuilder var content: Content
    @ActionBuilder var actions: [Action]
    var id = UUID()
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    content
                        .containerRelativeFrame(.horizontal)
                        .background {
                            GeometryReader { geometry in
                                let minX = geometry.frame(in: .scrollView).minX
                                if let firstAction = actions.first {
                                    Rectangle()
                                        .fill(-minX > 0 ? firstAction.buttonColor : .clear)
                                        .onChange(of: minX) {
                                            scrollMinX = minX
                                        }
                                }
                            }
                        }
                        .id(id)
                    ActionButtons {
                        withAnimation(.smooth) {
                            scrollProxy.scrollTo(id, anchor: .topLeading)
                        }
                    }
                }
                .scrollTargetLayout()
                .visualEffect { content, geometryProxy in
                    content
                        .offset(x: scrollOffset(proxy: geometryProxy))
                }
            }.scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .background {
                if let lastAction = actions.last {
                    -scrollMinX > 1 ? lastAction.buttonColor : .clear
                }
            }
        }
    }
    
    @ViewBuilder
    func ActionButtons(resetPosition: @escaping () -> ()) -> some View {
        Rectangle()
            .fill(.clear)
            .frame(width: CGFloat(actions.count) * 80)
            .overlay {
                HStack(spacing: 0) {
                    ForEach(actions) { action in
                        Button(action: {
                            resetPosition()
                            action.action()
                        }) {
                            Image(systemName: action.iconNm)
                                .foregroundStyle(action.iconColor)
                                .font(.title2)
                                .fontWeight(.medium)
                                .frame(width: 80)
                                .frame(maxHeight: .infinity)
                                .contentShape(.rect)
                        }.background(action.buttonColor)
                    }
                }
            }
    }
    
    func scrollOffset(proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        return minX > 0 ? -minX : 0
    }
}

struct Action: Identifiable {
    private(set) var id: UUID = .init()
    var buttonColor: Color
    var iconNm: String
    var iconColor = Color.white
    var action: () -> ()
}

@resultBuilder
struct ActionBuilder {
    static func buildBlock(_ components: Action...) -> [Action] {
        return components
    }
}

#Preview {
    ContentView()
}
