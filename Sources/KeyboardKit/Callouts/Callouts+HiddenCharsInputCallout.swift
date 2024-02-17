//
//  File.swift
//  
//
//  Created by Daulet Almagambetov on 11.02.2024.
//

import SwiftUI

extension Callouts {
    struct HiddenCharCallout: View {
        
        /**
         Create an input callout.
         
         - Parameters:
         - calloutContext: The callout context to use.
         - keyboardContext: The keyboard context to use.
         - style: The style to apply to the view, by default ``KeyboardStyle/InputCallout/standard``.
         */
        public init(
            calloutContext: Context,
            keyboardContext: KeyboardContext,
            style: Style = .standard
        ) {
            self._calloutContext = ObservedObject(wrappedValue: calloutContext)
            self._keyboardContext = ObservedObject(wrappedValue: keyboardContext)
            self.style = style
        }
        
        public typealias Context = CalloutContext.HiddenCharContext
        public typealias Style = KeyboardStyle.InputCallout
        
        @ObservedObject
        private var calloutContext: Context
        
        @ObservedObject
        private var keyboardContext: KeyboardContext

        private let style: Style
        
        public var body: some View {
            callout
                .transition(.opacity)
                .opacity(keyboardContext.isHiddenCharDragSelectionGestureActive ? 1 : 0)
                .keyboardCalloutShadow(style: style.callout)
                .position(position)
                .allowsHitTesting(false)
        }
    }
}

private extension Callouts.HiddenCharCallout {
    var callout: some View {
        VStack(spacing: 0) {
            calloutView.offset(
                x: callInputViewsOffset,
                y: 1
            )
            calloutButton
        }
        .compositingGroup()
    }

    @ViewBuilder
    var calloutView: some View {
        HStack(spacing: spacingBetweenCalloutInputs) {
            callInputView(value: calloutContext.input ?? "")

            alternativeInputs
        }
        .frame(minWidth: calloutSize.width, minHeight: calloutSize.height)
        .padding(.horizontal, horizontalPaddingCallout)
        .background(style.callout.backgroundColor)
        .cornerRadius(cornerRadius, corners: [.topLeft, .topRight, .bottomRight])
    }

    @ViewBuilder
    var alternativeInputs: some View {
        ForEach(0 ..< calloutContext.alternativeInputs.count, id: \.self) { index in
            callInputView(
                value: calloutContext.alternativeInputs[index]
            )
        }
    }

    var callInputViewsOffset: CGFloat {
        let buttonWidth = buttonFrame.width
        return (callInputViewsWidth - buttonWidth) / 2
    }

    var callInputViewsWidth: CGFloat {
        let calloutButtonWidth = calloutSelectionButtonSize.width
        let items = CGFloat(calloutContext.alternativeInputs.count + 1)
        let spacing = spacingBetweenCalloutInputs * (items - 1)
        let padding = horizontalPaddingCallout * 2
        return items * calloutButtonWidth + spacing + padding
    }

    func callInputView(value: String, isSelected: Bool) -> some View {
        Text(value)
            .font(style.font.font)
            .frame(width: calloutSelectionButtonSize.width, height: calloutSelectionButtonSize.height)
            .foregroundColor(isSelected ? Color.white : style.callout.textColor)
            .background(isSelected ? Color.blue : style.callout.backgroundColor)
            .cornerRadius(style.callout.buttonCornerRadius)
    }

    func callInputView(value: String) -> some View {
        GeometryReader { proxy in
            callInputView(value: value, isSelected: calloutContext.isSelected(value: value, for: proxy))
        }
        .frame(width: buttonSize.width * 0.9, height: buttonSize.height * 0.9)
        .cornerRadius(style.callout.buttonCornerRadius)
    }

    var calloutButton: some View {
        Callouts.ButtonArea(
            frame: buttonFrame,
            style: style.callout,
            isLeftCurveEnabled: false
        )
    }
}

private extension Callouts.HiddenCharCallout {
    var buttonFrame: CGRect {
        calloutContext.buttonFrame.insetBy(
            dx: buttonInset.width,
            dy: buttonInset.height)
    }
    
    var buttonInset: CGSize {
        style.callout.buttonInset
    }
    
    var buttonSize: CGSize {
        buttonFrame.size
    }
    
    var calloutSelectionButtonSize: CGSize {
        CGSize(width: buttonSize.width * 0.9, height: buttonSize.height * 0.9)
    }

    var horizontalPaddingCallout: CGFloat {
        8
    }

    var spacingBetweenCalloutInputs: CGFloat {
        4
    }

    var calloutSize: CGSize {
        CGSize(
            width: calloutSizeWidth,
            height: calloutSizeHeight
        )
    }
    
    var calloutSizeHeight: CGFloat {
        let smallSize = buttonSize.height
        return shouldEnforceSmallSize ? smallSize : style.calloutSize.height
    }
    
    var calloutSizeWidth: CGFloat {
        let minSize = buttonSize.width + 2 * style.callout.curveSize.width + style.callout.cornerRadius
        return max(style.calloutSize.width, minSize)
    }

    var cornerRadius: CGFloat {
        shouldEnforceSmallSize ? style.callout.buttonCornerRadius : style.callout.cornerRadius
    }
}

private extension Callouts.HiddenCharCallout {
    var shouldEnforceSmallSize: Bool {
        keyboardContext.deviceType == .phone && keyboardContext.interfaceOrientation.isLandscape
    }

    var position: CGPoint {
        guard !positionX.isInfinite && !positionY.isInfinite else {
            // when user touch up there are millisecond where
            // user see current view and x: 500 y: 500 values set not this blink to be visible
            return CGPoint(x: 500, y: 500)
        }

        return CGPoint(x: positionX, y: positionY)
    }

    var positionX: CGFloat {
        buttonFrame.origin.x + buttonSize.width/2
    }

    var positionY: CGFloat {
        let base = buttonFrame.origin.y + buttonSize.height/2 - calloutSize.height/2
        let isEmoji = calloutContext.action?.isEmojiAction == true
        if isEmoji { return base + 5 }
        return base
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
