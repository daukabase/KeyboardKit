//
//  InputSet+Item.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-03.
//  Copyright © 2021-2023 Daniel Saidi. All rights reserved.
//

import Foundation

public extension InputSet {
    
    /**
     This struct represents an input set item with a neutral,
     uppercased and lowercased variant.
     
     You can create an instance with just a string, which is
     the regular way of working with input sets. However, it
     also supports specific casings, which means that we can
     use it to create unicode keyboards etc.
     */
    struct Item {
        
        /**
         Create an input set item.
         
         - Parameters:
           - char: The char to use for all casings.
         */
        public init(_ char: String, hidden: Item? = nil) {
            self.neutral = char
            self.uppercased = char.uppercased()
            self.lowercased = char.lowercased()
            self._hidden = hidden.map(Box.init)
        }
        
        /**
         Create an input set item with individual characters.
         
         - Parameters:
           - neutral: The neutral char value.
           - uppercased: The uppercased char value.
           - lowercased: The lowercased char value.
         */
        public init(
            neutral: String,
            uppercased: String,
            lowercased: String,
            hidden: Item? = nil
        ) {
            self.neutral = neutral
            self.uppercased = uppercased
            self.lowercased = lowercased
            self._hidden = hidden.map(Box.init)
        }
        
        /// The neutral char value.
        public var neutral: String
        
        /// The uppercased char value.
        public var uppercased: String
        
        /// The lowercased char value.
        public var lowercased: String

        public var hiddenCharacter: Item? {
            return _hidden?.boxed
        }
        private var _hidden: Box<Item>?

        /// Resolve the character to use for a certain case.
        public func character(for case: Keyboard.Case) -> String {
            switch `case` {
            case .auto: return lowercased
            case .lowercased: return lowercased
            case .uppercased, .capsLocked: return uppercased
            }
        }
    }
}

extension InputSet.Item: KeyboardLayoutRowItem {

    /// The row-specific ID to use for the action.
    public var rowId: InputSet.Item { self }
}

extension InputSet.Item: Equatable {
    public static func == (lhs: InputSet.Item, rhs: InputSet.Item) -> Bool {
        return lhs.neutral == rhs.neutral &&
            lhs.uppercased == rhs.uppercased &&
            lhs.lowercased == rhs.lowercased &&
            lhs._hidden?.boxed == rhs._hidden?.boxed
    }
}

private class Box<T> {
   let boxed: T
   init(_ thingToBox: T) { boxed = thingToBox }
}
