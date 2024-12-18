//
//  KeyboardLayoutIdentifiable.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-05-08.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import Foundation

/// This protocol can be implemented by any type that can be
/// used as an ID-based layout item.
///
/// Implementing the protocol unlocks extensions that can be
/// used to handle and modify keyboard layout items.
///
/// Unlike `Identifiable`, the ``rowId`` does not have to be
/// unique, since items may appear many times in a layout.
public protocol KeyboardLayoutIdentifiable {
    
    associatedtype ID: Equatable
    
    /// The layout-specific item identifier.
    var rowId: ID { get }
}

extension InputSet.Item: KeyboardLayoutIdentifiable {

    public var rowId: Self { self }
}

extension KeyboardLayout.Item: KeyboardLayoutIdentifiable {

    public var rowId: KeyboardAction { action }
}

public extension RangeReplaceableCollection where Element: KeyboardLayoutIdentifiable, Index == Int {

    /// Get the index of a certain item in the collection.
    func index(
        of item: Element
    ) -> Index? {
        index(of: item.rowId)
    }

    /// Get the index of a certain item id in the collection.
    func index(
        of id: Element.ID
    ) -> Index? {
        firstIndex { $0.rowId == id }
    }

    /// Insert an item after another item in the collection.
    mutating func insert(
        _ item: Element,
        after target: Element
    ) {
        insert(item, after: target.rowId)
    }
    
    /// Insert an item after another item in the collection.
    mutating func insert(
        _ item: Element,
        after id: Element.ID
    ) {
        guard let index = index(of: id) else { return }
        insert(item, at: index.advanced(by: 1))
    }

    /// Insert an item before another item in the collection.
    mutating func insert(
        _ item: Element,
        before target: Element
    ) {
        insert(item, before: target.rowId)
    }
    
    /// Insert an item before another item in the collection.
    mutating func insert(
        _ item: Element,
        before id: Element.ID
    ) {
        guard let index = index(of: id) else { return }
        insert(item, at: index)
    }
    
    /// Remove a certain item from the collection.
    mutating func remove(
        _ item: Element
    ) {
        remove(item.rowId)
    }
    
    /// Remove a certain item from the collection.
    mutating func remove(
        _ id: Element.ID
    ) {
        while let index = index(of: id) {
            remove(at: index)
        }
    }

    /// Replace an item with another item in the collection.
    mutating func replace(
        _ item: Element,
        with replacement: Element
    ) {
        insert(replacement, after: item)
        remove(item)
    }

    /// Replace an item with another item in the collection.
    mutating func replace(
        _ id: Element.ID,
        with replacement: Element
    ) {
        guard let index = index(of: id) else { return }
        insert(replacement, after: id)
        remove(at: index)
    }
}

public extension Array where
    Element: RangeReplaceableCollection,
    Element.Index == Int,
    Element.Element: KeyboardLayoutIdentifiable {
    
    /// Get the row at a certain index.
    func row(
        at index: Int
    ) -> Element? {
        guard index >= 0, count > index else { return nil }
        return self[index]
    }

    /// Insert an item after another item in all rows.
    mutating func insert(
        _ item: Element.Element,
        after target: Element.Element
    ) {
        insert(item, after: target.rowId)
    }
    
    /// Insert an item after another item in all rows.
    mutating func insert(
        _ item: Element.Element,
        after target: Element.Element.ID
    ) {
        enumerated().forEach {
            insert(item, after: target, atRow: $0.offset)
        }
    }

    /// Insert an item after another item in a certain row.
    mutating func insert(
        _ item: Element.Element,
        after target: Element.Element,
        atRow index: Int
    ) {
        insert(item, after: target.rowId, atRow: index)
    }
    
    /// Insert an item after another item on a certain row.
    mutating func insert(
        _ item: Element.Element,
        after target: Element.Element.ID,
        atRow index: Int
    ) {
        guard var row = self.row(at: index) else { return }
        row.insert(item, after: target)
        self[index] = row
    }

    /// Insert an item before another item in all rows.
    mutating func insert(
        _ item: Element.Element,
        before target: Element.Element
    ) {
        insert(item, before: target.rowId)
    }
    
    /// Insert an item before another item in all rows.
    mutating func insert(
        _ item: Element.Element,
        before target: Element.Element.ID
    ) {
        enumerated().forEach {
            insert(item, before: target, atRow: $0.offset)
        }
    }

    /// Insert an item before another item in a certain row.
    mutating func insert(
        _ item: Element.Element,
        before target: Element.Element,
        atRow index: Int
    ) {
        insert(item, before: target.rowId, atRow: index)
    }
    
    /// Insert an item before another item in a certain row.
    mutating func insert(
        _ item: Element.Element,
        before target: Element.Element.ID,
        atRow index: Int
    ) {
        guard var row = self.row(at: index) else { return }
        row.insert(item, before: target)
        self[index] = row
    }
    
    /// Remove a certain item in all rows.
    mutating func remove(
        _ item: Element.Element
    ) {
        remove(item.rowId)
    }
    
    /// Remove a certain item item in all rows.
    mutating func remove(
        _ id: Element.Element.ID
    ) {
        enumerated().forEach {
            remove(id, atRow: $0.offset)
        }
    }

    /// Remove a certain item in a certain row.
    mutating func remove(
        _ item: Element.Element,
        atRow index: Int
    ) {
        remove(item.rowId, atRow: index)
    }

    /// Remove a certain item at a certain row.
    mutating func remove(
        _ id: Element.Element.ID,
        atRow index: Int
    ) {
        guard var row = self.row(at: index) else { return }
        row.remove(id)
        self[index] = row
    }

    /// Replace an item with another item in all rows.
    mutating func replace(
        _ item: Element.Element,
        with replacement: Element.Element
    ) {
        replace(item.rowId, with: replacement)
    }

    /// Replace an item with another item in all rows.
    mutating func replace(
        _ item: Element.Element.ID,
        with replacement: Element.Element
    ) {
        enumerated().forEach {
            replace(item, with: replacement, atRow: $0.offset)
        }
    }

    /// Replace an item with another item in a certain row.
    mutating func replace(
        _ item: Element.Element,
        with replacement: Element.Element,
        atRow index: Int
    ) {
        replace(item.rowId, with: replacement, atRow: index)
    }

    /// Replace an item with another item in a certain row.
    mutating func replace(
        _ item: Element.Element.ID,
        with replacement: Element.Element,
        atRow index: Int
    ) {
        guard var row = self.row(at: index) else { return }
        row.replace(item, with: replacement)
        self[index] = row
    }
}
