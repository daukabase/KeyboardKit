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
                x: 0,
                y: 1
            )
            calloutButton
        }
        .compositingGroup()
    }

    @ViewBuilder
    var calloutView: some View {
        HStack(spacing: 2) {
            callInputView(value: calloutContext.input ?? "", isSelected: calloutContext.selectedCharIndex == 0)

            ForEach(0 ..< calloutContext.alternativeInputs.count, id: \.self) { index in
                callInputView(
                    value: calloutContext.alternativeInputs[index],
                    isSelected: calloutContext.selectedCharIndex == index + 1
                )
            }
        }
        .frame(minWidth: calloutSize.width, minHeight: calloutSize.height)
        .background(Color.white)
        .cornerRadius(cornerRadius)
    }

    func callInputView(value: String, isSelected: Bool) -> some View {
        Text(value)
            .font(style.font.font)
            .frame(minWidth: 16)
            .foregroundColor(isSelected ? Color.white : style.callout.textColor)
            .background(isSelected ? Color.blue : style.callout.backgroundColor)
            .cornerRadius(cornerRadius)
    }

    var calloutButton: some View {
        Callouts.ButtonArea(
            frame: buttonFrame,
            style: style.callout
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
        CGPoint(x: positionX, y: positionY)
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

