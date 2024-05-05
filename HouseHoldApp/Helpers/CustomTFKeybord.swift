//
//  CustomTFKeybord.swift
//  HouseHoldApp
//
//  Created by 青木択斗 on 2023/11/17.
//

import SwiftUI

extension View {
    @ViewBuilder
    func inputView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .background(
                SetTFKeybord(keybordContent: content())
            )
    }
}

fileprivate struct SetTFKeybord<Content: View>: UIViewRepresentable {
    var keybordContent: Content
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            if let textFieldContainerView = uiView.superview?.superview {
                if let textField = textFieldContainerView.findTextField {
                    let hostingController = UIHostingController(rootView: keybordContent)
                    hostingController.view.frame = .init(origin: .zero, size: hostingController.view.intrinsicContentSize)
                    textField.inputView = hostingController.view
                } else {
                    print("failed")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

fileprivate extension UIView {
    var allSubViews: [UIView] {
        return subviews.flatMap{ [$0] + $0.subviews }
    }
    var findTextField: UITextField? {
        if let textField = allSubViews.first(where: { view in
            view is UITextField
        }) as? UITextField {
            return textField
        }
        
        return nil
    }
}
