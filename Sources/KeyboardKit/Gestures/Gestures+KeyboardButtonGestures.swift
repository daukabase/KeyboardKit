//
//  Gestures+KeyboardButtonGestures.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-01-10.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

#if os(iOS) || os(macOS) || os(watchOS)
import SwiftUI

extension Gestures {
    
    /**
     This view applies keyboard gestures to any content view.
     */
    struct KeyboardButtonGestures<Content: View>: View {
        
        /**
         Apply a set of optional gesture actions to the provided
         view, for a certain keyboard action.
         
         - Parameters:
           - view: The view to apply the gestures to.
           - action: The keyboard action to trigger.
           - calloutContext: The callout context to affect, if any.
           - isPressed: An optional binding that can be used to observe the button pressed state.
           - isInScrollView: Whether or not the gestures are used in a scroll view.
           - releaseOutsideTolerance: The percentage of the button size that should span outside the button bounds and still count as a release, by default `0.75`.
           - doubleTapAction: The action to trigger when the button is double tapped.
           - longPressAction: The action to trigger when the button is long pressed.
           - pressAction: The action to trigger when the button is pressed.
           - releaseAction: The action to trigger when the button is released, regardless of where the gesture ends.
           - repeatAction: The action to trigger when the button is pressed and held.
           - dragAction: The action to trigger when the button is dragged.
         */
        init(
            view: Content,
            action: KeyboardAction?,
            calloutContext: CalloutContext?,
            hiddenCharContext: CalloutContext.HiddenCharContext?,
            isPressed: Binding<Bool>,
            isInScrollView: Bool,
            releaseOutsideTolerance: Double,
            doubleTapAction: KeyboardGestureAction?,
            longPressAction: KeyboardGestureAction?,
            pressAction: KeyboardGestureAction?,
            releaseAction: KeyboardGestureAction?,
            repeatAction: KeyboardGestureAction?,
            dragAction: KeyboardDragGestureAction?
        ) {
            self.view = view
            self.action = action
            self.calloutContext = calloutContext
            self.hiddenCharContext = hiddenCharContext
            self.isPressed = isPressed
            self.isInScrollView = isInScrollView
            self.releaseOutsideTolerance = releaseOutsideTolerance
            self.doubleTapAction = doubleTapAction
            self.longPressAction = longPressAction
            self.pressAction = pressAction
            self.releaseAction = releaseAction
            self.repeatAction = repeatAction
            self.dragAction = dragAction
        }
        
        private let view: Content
        private let action: KeyboardAction?
        private let calloutContext: CalloutContext?
        private let hiddenCharContext: CalloutContext.HiddenCharContext?
        private let isPressed: Binding<Bool>
        private let isInScrollView: Bool
        private let releaseOutsideTolerance: Double
        private let doubleTapAction: KeyboardGestureAction?
        private let longPressAction: KeyboardGestureAction?
        private let pressAction: KeyboardGestureAction?
        private let releaseAction: KeyboardGestureAction?
        private let repeatAction: KeyboardGestureAction?
        private let dragAction: KeyboardDragGestureAction?
        
        @State
        private var lastDragValue: DragGesture.Value?
        
        @State
        private var shouldApplyReleaseAction = true
        
        var body: some View {
            view.overlay(
                GeometryReader { geo in
                    button(for: geo)
                }
            )
        }
    }
}

private extension View {

    @ViewBuilder
    func optionalGesture<GestureType: Gesture>(_ gesture: GestureType?) -> some View {
        if let gesture = gesture {
            self.gesture(gesture)
        } else {
            self
        }
    }
}

// MARK: - Views

private extension Gestures.KeyboardButtonGestures {

    @ViewBuilder
    func button(for geo: GeometryProxy) -> some View {
        if isInScrollView {
            scrollButton(for: geo)
        } else {
            gestureButton(for: geo)
        }
    }

    func gestureButton(for geo: GeometryProxy) -> some View {
        Gestures.GestureButton(
            isPressed: isPressed,
            pressAction: { handlePress(in: geo) },
            releaseInsideAction: { handleReleaseInside(in: geo) },
            releaseOutsideAction: { handleReleaseOutside(in: geo) },
            longPressAction: { handleLongPress(in: geo) },
            doubleTapAction: { handleDoubleTap(in: geo) },
            repeatAction: { handleRepeat(in: geo) },
            dragAction: { handleDrag(in: geo, value: $0) },
            endAction: { handleGestureEnded(in: geo) },
            label: { _ in Color.clearInteractable }
        )
    }

    func scrollButton(for geo: GeometryProxy) -> some View {
        Gestures.ScrollViewGestureButton(
            isPressed: isPressed,
            pressAction: { handlePress(in: geo) },
            releaseInsideAction: { handleReleaseInside(in: geo) },
            releaseOutsideAction: { handleReleaseOutside(in: geo) },
            longPressAction: { handleLongPress(in: geo) },
            doubleTapAction: { handleDoubleTap(in: geo) },
            repeatAction: { handleRepeat(in: geo) },
            dragAction: { handleDrag(in: geo, value: $0) },
            endAction: { handleGestureEnded(in: geo) },
            label: { _ in Color.clearInteractable }
        )
    }
}


// MARK: - Actions

private extension Gestures.KeyboardButtonGestures {

    func handleDoubleTap(in geo: GeometryProxy) {
        doubleTapAction?()
    }

    func handleDrag(in geo: GeometryProxy, value: DragGesture.Value) {
        lastDragValue = value
        calloutContext?.actionContext.updateSelection(with: value.translation)
        dragAction?(value.startLocation, value.location)
    }

    func handleGestureEnded(in geo: GeometryProxy) {
        endActionCallout()
        calloutContext?.inputContext.resetWithDelay()
        calloutContext?.actionContext.reset()
        hiddenCharContext?.reset()
        resetGestureState()
    }

    func handleLongPress(in geo: GeometryProxy) {
        tryBeginActionCallout(in: geo)
        longPressAction?()
        hiddenCharContext?.updateInput(for: action, in: geo)
    }

    func handlePress(in geo: GeometryProxy) {
        pressAction?()
        calloutContext?.inputContext.updateInput(for: action, in: geo)
    }

    func handleReleaseInside(in geo: GeometryProxy) {
        updateShouldApplyReleaseAction()
        guard shouldApplyReleaseAction else { return }
        releaseAction?()
    }

    func handleReleaseOutside(in geo: GeometryProxy) {
        guard shouldApplyReleaseOutsize(for: geo) else { return }
        handleReleaseInside(in: geo)
    }

    func handleRepeat(in geo: GeometryProxy) {
        repeatAction?()
    }

    func tryBeginActionCallout(in geo: GeometryProxy) {
        guard let context = calloutContext?.actionContext else { return }
        context.updateInputs(for: action, in: geo)
        guard context.isActive else { return }
        calloutContext?.inputContext.reset()
    }

    func endActionCallout() {
        calloutContext?.actionContext.endDragGesture()
    }

    func resetGestureState() {
        lastDragValue = nil
        shouldApplyReleaseAction = true
    }

    func shouldApplyReleaseOutsize(for geo: GeometryProxy) -> Bool {
        if hiddenCharContext?.isActive == true {
            return true
        }
        guard let dragValue = lastDragValue else { return false }
        let rect = CGRect.releaseOutsideToleranceArea(for: geo, tolerance: releaseOutsideTolerance)
        let isInsideRect = rect.contains(dragValue.location)
        return isInsideRect
    }

    func updateShouldApplyReleaseAction() {
        guard let context = calloutContext?.actionContext else { return }
        shouldApplyReleaseAction = shouldApplyReleaseAction && !context.hasSelectedAction
    }
}

extension CGRect {

    /// Return a rect with release outside tolerance padding.
    static func releaseOutsideToleranceArea(
        for geo: GeometryProxy,
        tolerance: Double
    ) -> CGRect {
        let size = geo.size
        let rect = CGRect(origin: .zero, size: geo.size)
            .insetBy(dx: -size.width * tolerance, dy: -size.height * tolerance)
        return rect
    }
}
#endif
