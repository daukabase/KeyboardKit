//
//  StandardKeyboardBehavior.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-12-28.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 This class defines how a standard, Western keyboard behaves.
 
 You can inherit this class and override any open properties
 and functions to customize the standard behavior.
 
 This class makes heavy use of standard logic that's defined
 elsewhere. However, having this makes it easy to change the
 actual behavior.
 
 KeyboardKit automatically creates an instance of this class
 and binds it to ``KeyboardInputViewController/services``.
 
 > Note: This class handles `shift` a bit different since it
 must handle double taps to switch to caps lock. Due to this,
 it must not switch to the preferred keyboard, but must also
 always try to do so. This behavior is tested to ensure that
 it is behaving as it should.
 */
open class StandardKeyboardBehavior: KeyboardBehavior {

    /**
      Create a standard keyboard behavior instance.

      - Parameters:
        - keyboardContext: The keyboard context to use.
        - doubleTapThreshold: The second threshold to detect a tap as a double tap, by default `0.5`.
        - endSentenceThreshold: The second threshold during which a sentence can be auto-closed, by default `3.0`.
        - repeatGestureTimer: A timer that is responsible for triggering a repeat gesture action, by default ``Gestures/RepeatTimer/shared``.
     */
    public init(
        keyboardContext: KeyboardContext,
        doubleTapThreshold: TimeInterval = 0.5,
        endSentenceThreshold: TimeInterval = 3.0,
        repeatGestureTimer: Gestures.RepeatTimer = .shared
    ) {
        self.keyboardContext = keyboardContext
        self.doubleTapThreshold = doubleTapThreshold
        self.endSentenceThreshold = endSentenceThreshold
        self.repeatGestureTimer = repeatGestureTimer
    }


    /// The keyboard context to use.
    public let keyboardContext: KeyboardContext

    /// The second threshold to detect a tap as a double tap.
    public let doubleTapThreshold: TimeInterval

    /// The second threshold during which a sentence can be auto-closed.
    public let endSentenceThreshold: TimeInterval

    /// A timer that is responsible for triggering a repeat gesture action.
    public let repeatGestureTimer: Gestures.RepeatTimer


    /// An internal state to keep track of shift checks.
    var lastShiftCheck = Date()
    
    /// An internal state to keep track of the last space tap.
    var lastSpaceTap = Date()
    
    
    /**
     The range that the backspace key should delete when the
     key is long pressed.
     */
    public var backspaceRange: Keyboard.BackspaceRange {
        let duration = repeatGestureTimer.duration ?? 0
        return duration > 3 ? .word : .character
    }
    
    /**
     The preferred keyboard type that should be applied when
     a certain gesture has been performed on an action.
     */
    public func preferredKeyboardType(
        after gesture: Gesture,
        on action: KeyboardAction
    ) -> Keyboard.KeyboardType {
        if shouldSwitchToCapsLock(after: gesture, on: action) { return .alphabetic(.capsLocked) }
        if action.isAlternateQuotationDelimiter(for: keyboardContext) { return .alphabetic(.lowercased) }
        let should = shouldSwitchToPreferredKeyboardType(after: gesture, on: action)
        switch action {
        case .shift: return keyboardContext.keyboardType
        default: return should ? keyboardContext.preferredKeyboardType : keyboardContext.keyboardType
        }
    }
    
    /**
     Whether or not to end the currently typed sentence when
     a certain gesture has been performed on an action.
     */
    open func shouldEndSentence(
        after gesture: Gesture,
        on action: KeyboardAction
    ) -> Bool {
        #if os(iOS) || os(tvOS)
        guard gesture == .release, action == .space else { return false }
        let proxy = keyboardContext.textDocumentProxy
        let isNewWord = proxy.isCursorAtNewWord
        let isNewSentence = proxy.isCursorAtNewSentence
        let isClosable = (proxy.documentContextBeforeInput ?? "").hasSuffix("  ")
        let isEndingTap = Date().timeIntervalSinceReferenceDate - lastSpaceTap.timeIntervalSinceReferenceDate < endSentenceThreshold
        let shouldClose = isEndingTap && isNewWord && !isNewSentence && isClosable
        lastSpaceTap = Date()
        return shouldClose
        #else
        return false
        #endif
    }
    
    /**
     Whether or not to switch to capslock when a gesture has
     been performed on an action.
     */
    open func shouldSwitchToCapsLock(
        after gesture: Gesture,
        on action: KeyboardAction
    ) -> Bool {
        switch action {
        case .shift: return isDoubleShiftTap
        default: return false
        }
    }
    
    /**
     Whether or not to switch to the preferred keyboard type
     when a certain gesture has been performed on an action.
     */
    open func shouldSwitchToPreferredKeyboardType(
        after gesture: Gesture,
        on action: KeyboardAction
    ) -> Bool {
        // if action.isAlternateQuotationDelimiter(for: context) { return true }
        switch action {
        case .backspace: return isPreferredKeyboardDifferent
        case .keyboardType(let type): return type.shouldSwitchToPreferredKeyboardType
        case .shift: return true
        default:
            let isRelease = gesture == .release
            let isDifferent = isPreferredKeyboardDifferent
            return isRelease && isDifferent
        }
    }
    
    /**
     Whether or not to switch to the preferred keyboard type
     after the text document proxy text did change.
     */
    public func shouldSwitchToPreferredKeyboardTypeAfterTextDidChange() -> Bool {
        isPreferredKeyboardDifferent
    }
}

private extension StandardKeyboardBehavior {
    
    var isPreferredKeyboardDifferent: Bool {
        let current = keyboardContext.keyboardType
        let preferred = keyboardContext.preferredKeyboardType
        return current != preferred
    }
    
    var isDoubleShiftTap: Bool {
        guard keyboardContext.keyboardType.isAlphabetic else { return false }
        let date = Date().timeIntervalSinceReferenceDate
        let lastDate = lastShiftCheck.timeIntervalSinceReferenceDate
        let isDoubleTap = (date - lastDate) < doubleTapThreshold
        lastShiftCheck = isDoubleTap ? Date().addingTimeInterval(-1) : Date()
        return isDoubleTap
    }
}

private extension KeyboardAction {
    
    func isAlternateQuotationDelimiter(for context: KeyboardContext) -> Bool {
        switch self {
        case .character(let char), .characterWithHidden(let char, _): 
            return char.isAlternateQuotationDelimiter(for: context)
        default: return false
        }
    }
}

private extension String {
    
    func isAlternateQuotationDelimiter(for context: KeyboardContext) -> Bool {
        let locale = context.locale
        return self == locale.alternateQuotationBeginDelimiter || self == locale.alternateQuotationEndDelimiter
    }
}

private extension Keyboard.KeyboardType {
    
    var shouldSwitchToPreferredKeyboardType: Bool {
        switch self {
        case .alphabetic(let state): return state.shouldSwitchToPreferredKeyboardType
        default: return false
        }
    }
}

private extension Keyboard.Case {
    
    var shouldSwitchToPreferredKeyboardType: Bool {
        switch self {
        case .auto: return true
        default: return false
        }
    }
}
