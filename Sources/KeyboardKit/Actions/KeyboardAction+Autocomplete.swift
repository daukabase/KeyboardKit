//
//  KeyboardAction+Actions.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-03-18.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

public extension KeyboardAction {
    
    /**
     Whether or not the action should apply any autocomplete
     suggestions where `isAutocorrect`  is true.
     */
    var shouldApplyAutocorrectSuggestion: Bool {
        switch self {
        case .character(let char), .characterWithHidden(let char, _):
            return char.isWordDelimiter
        case .primary(let type): return type.isSystemAction
        case .space: return true
        default: return false
        }
    }
    
    /**
     Whether or not the action should insert an autocomplete
     removed space.
     */
    var shouldReinsertAutocompleteInsertedSpace: Bool {
        shouldRemoveAutocompleteInsertedSpace
    }
    
    /**
     Whether or not the action should remove an autocomplete
     inserted space.
     */
    var shouldRemoveAutocompleteInsertedSpace: Bool {
        switch self {
        case .character(let char), .characterWithHidden(let char, _): 
            return char.isWordDelimiter && self != .space
        default: return false
        }
    }
}
