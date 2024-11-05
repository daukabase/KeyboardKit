//
//  Callouts+InputCallout.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-06.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import SwiftUI

public extension Callouts {
    
    /// This callout can show the pressed char in a callout.
    ///
    /// In iOS, this callout is presented when a button with
    /// an input character is pressed.
    struct InputCallout: View {
        
        /// Create a custom input callout.
        ///
        /// - Parameters:
        ///   - calloutContext: The callout context to use.
        ///   - keyboardContext: The keyboard context to use.
        public init(
            calloutContext: CalloutContext,
            keyboardContext: KeyboardContext
        ) {
            self._calloutContext = .init(wrappedValue: calloutContext)
            self._keyboardContext = .init(wrappedValue: keyboardContext)
        }
        
        @ObservedObject
        private var calloutContext: CalloutContext

        @ObservedObject
        private var keyboardContext: KeyboardContext
        
        @Environment(\.calloutStyle)
        private var style

        public var body: some View {
            callout
                .transition(.opacity)
                .opacity(isCalloutActive ? 1 : 0)
                .keyboardCalloutShadow(style: style)
                .position(position)
                .allowsHitTesting(false)
        }
    }
}

private extension Callouts.InputCallout {

    var callout: some View {
        VStack(spacing: 0) {
            calloutBubble.offset(y: 1)
            calloutButton
        }
        .compositingGroup()
    }

    var calloutBubble: some View {
        Text(calloutContext.inputAction?.inputCalloutText ?? "")
            .font(style.inputItemFont.font)
            .frame(minWidth: calloutSize.width, minHeight: calloutSize.height)
            .foregroundColor(style.foregroundColor)
            .background(style.backgroundColor)
            .cornerRadius(cornerRadius)
    }
    
    var calloutButton: some View {
        ButtonArea(frame: buttonFrame)
            .calloutStyle(style)
    }
}

private extension Callouts.InputCallout {
    
    var buttonFrame: CGRect {
        calloutContext.buttonFrame.insetBy(
            dx: buttonInset.width,
            dy: buttonInset.height)
    }
    
    var buttonInset: CGSize {
        style.buttonOverlayInset
    }
    
    var buttonSize: CGSize {
        buttonFrame.size
    }
    
    var calloutSize: CGSize {
        CGSize(
            width: calloutSizeWidth,
            height: calloutSizeHeight
        )
    }
    
    var calloutSizeHeight: CGFloat {
        let smallSize = buttonSize.height
        let calloutSize = style.inputItemMinSize
        return shouldEnforceSmallSize ? smallSize : calloutSize.height
    }
    
    var calloutSizeWidth: CGFloat {
        let minSize = buttonSize.width + 2 * style.curveSize.width + style.cornerRadius
        let calloutSize = style.inputItemMinSize
        return max(calloutSize.width, minSize)
    }
    
    var cornerRadius: CGFloat {
        shouldEnforceSmallSize ? style.buttonOverlayCornerRadius : style.cornerRadius
    }
}

private extension Callouts.InputCallout {

    var isCalloutActive: Bool {
        isCalloutEnabled && calloutContext.inputAction != nil
    }

    var isCalloutEnabled: Bool {
        keyboardContext.deviceTypeForKeyboard == .phone
    }

    var shouldEnforceSmallSize: Bool {
        keyboardContext.deviceTypeForKeyboard == .phone && keyboardContext.interfaceOrientation.isLandscape
    }

    var position: CGPoint {
        CGPoint(x: positionX, y: positionY)
    }

    var positionX: CGFloat {
        buttonFrame.origin.x + buttonSize.width/2
    }

    var positionY: CGFloat {
        let base = buttonFrame.origin.y + buttonSize.height/2 - calloutSize.height/2
        let isEmoji = calloutContext.inputAction?.isEmojiAction == true
        if isEmoji { return base + 5 }
        return base
    }
}


// MARK: - Previews

#if os(iOS) || os(macOS) || os(watchOS)
#Preview {

    struct Preview: View {

        @StateObject
        var context = CalloutContext()

        func button(for context: CalloutContext) -> some View {
            GeometryReader { geo in
                GestureButton(
                    pressAction: { showCallout(for: geo) },
                    endAction: context.resetInputActionWithDelay,
                    label: { _ in Color.red.cornerRadius(5) }
                )
            }
            .frame(width: 40, height: 40)
            .padding()
            .background(Color.yellow.cornerRadius(6))
        }

        func showCallout(for geo: GeometryProxy) {
            context.updateInputAction(.character("a"), in: geo)
        }

        var buttonStack: some View {
            HStack {
                button(for: context)
                button(for: context)
                button(for: context)
            }
        }

        var body: some View {
            VStack {
                buttonStack
                buttonStack
                Button("Reset") {
                    context.resetInputAction()
                }
            }
            .keyboardInputCalloutContainer(
                calloutContext: context,
                keyboardContext: .preview
            )
        }
    }

    return Preview()
        .calloutStyle(.init(
            backgroundColor: .blue,
            foregroundColor: .yellow
        ))
}
#endif
