//
//  InputSet.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2020-07-03.
//  Copyright © 2020-2023 Daniel Saidi. All rights reserved.
//

import Foundation

/**
 An input set defines the input keys on a keyboard.
 
 Input sets can be used to create a ``KeyboardLayout`` which
 defines the full set of keys of a keyboard, often including
 keys around the input rows and a bottom system row.
 
 KeyboardKit has a couple of pre-defined input sets, such as
 standard ``qwerty``, a ``standardNumeric(currency:)`` and a
 ``standardSymbolic(currencies:)``. KeyboardKit Pro provides
 even more input sets like `qwertz` and `azerty`, as well as
 alphabetic, numeric and symbolic input sets for all locales.
 */
public struct InputSet: Equatable {
    
    /// Create an input set with rows.
    public init(rows: Rows) {
        self.rows = rows
    }

    /// The rows in the input set.
    public var rows: Rows
}

public extension InputSet {
    
    static var qwerty: InputSet {
        .init(rows: [
            .init(chars: "qwertyuiop"),
            .init(chars: "asdfghjkl"),
            .init(phone: "zxcvbnm", pad: "zxcvbnm,.")
        ])
    }

    static var russian: InputSet {
        .init(rows: [
            .init(chars: "йцукенгшщзх"),
            .init(chars: "фывапролджэ"),
            qazaqThirdRow
        ])
    }

    static var neoQazaq: InputSet {
        .init(rows: [
            qazaqFirstRow,
            .init(chars: "фывапролджэ"),
            qazaqThirdRow
        ])
    }

    static var qazaqFirstRow: InputSet.Row {
        let firstPart: [InputSet.Item] = InputSet.Row(chars: "йцуке")
        let middlePart1 = [InputSet.Item("н", hidden: InputSet.Item("ң"))]
        let middlePart2 = [InputSet.Item("г", hidden: InputSet.Item("ғ"))]
        let thirdPart: [InputSet.Item] = InputSet.Row(chars: "шщзх")

        let row = firstPart + middlePart1 + middlePart2 + thirdPart
        return row
    }

    static var qazaqThirdRow: InputSet.Row {
        let firstPart: [InputSet.Item] = InputSet.Row(chars: "ячсмит")
        let secondPart = [InputSet.Item("ь", hidden: InputSet.Item("ъ"))]
        let thirdPart: [InputSet.Item] = InputSet.Row(chars: "бю")

        let row = firstPart + secondPart + thirdPart
        return row
    }

    static func standardNumeric(currency: String) -> InputSet {
        .init(rows: [
            .init(chars: "1234567890"),
            .init(phone: "-/:;()\(currency)&@”", pad: "@#\(currency)&*()’”"),
            .init(phone: ".,?!’", pad: "%-+=/;:!?")
        ])
    }
    
    static func rusisanNumeric(currency: String) -> InputSet {
        .init(rows: [
            .init(chars: "1234567890"),
            .init(phone: "-/:;()\(currency)&@”", pad: "@#\(currency)&*()’”"),
            .init(phone: ".,?!’", pad: "%-+=/;:!?")
        ])
    }
    
    static func standardSymbolic(currencies: [String]) -> InputSet {
        .init(rows: [
            .init(phone: "[]{}#%^*+=", pad: "1234567890"),
            .init(
                phone: "_\\|~<>\(currencies.joined())•",
                pad: "\(currencies.joined())_^[]{}"),
            .init(phone: ".,?!’", pad: "§|~…\\<>!?")
        ])
    }
}
