//
//  Keyboard+Toolbar.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2024-03-18.
//  Copyright © 2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

public extension Keyboard {
    
    /// This view can be used to render a toolbar with a min
    /// height, to ensure that callouts are not cut off.
    ///
    /// You can style this component with the style modifier
    /// ``keyboardToolbarStyle(_:)``.
    struct Toolbar<Content: View>: View {
        
        public init(
            @ViewBuilder content: @escaping () -> Content
        ) {
            self.content = content
        }
        
        @ViewBuilder
        private let content: () -> Content
        
        @Environment(\.keyboardToolbarStyle)
        private var style
        
        public var body: some View {
            content()
                .frame(maxWidth: .infinity)
                .frame(height: style.height)
                .frame(minHeight: style.minHeight, maxHeight: style.maxHeight)
                .background(style.backgroundColor)
        }
    }
}

#Preview {
    
    VStack(spacing: 0) {
        Color.blue
        Keyboard.Toolbar {
            VStack {
                Text(".")
            }
        }
        Color.blue
    }
    .background(Color.keyboardBackground)
    .keyboardToolbarStyle(.init(
        height: 350
    ))
}
