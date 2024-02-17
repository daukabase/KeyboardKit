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
            russianThirdRow
        ])
    }

    static var neoQazaq: InputSet {
        .init(rows: [
            qazaqFirstRow,
            qazaqSecondRow,
            qazaqThirdRow
        ])
    }

    static var qazaqFirstRow: InputSet.Row {
        let iTs: [InputSet.Item] = InputSet.Row(chars: "йц")

        let u: [InputSet.Item] = [InputSet.Item("у", hiddenChars: [InputSet.Item("ұ"), InputSet.Item("ү")])]
        let k = [InputSet.Item("к", hidden: InputSet.Item("қ"))]
        let e = [InputSet.Item("е", hidden: InputSet.Item("ё"))]
        let n = [InputSet.Item("н", hidden: InputSet.Item("ң"))]
        let g = [InputSet.Item("г", hidden: InputSet.Item("ғ"))]
        let shShhZ: [InputSet.Item] = InputSet.Row(chars: "шщз")
        let x = [InputSet.Item("х", hidden: InputSet.Item("һ"))]

        // compile type-check error
        var row = [InputSet.Item]()
        row.append(contentsOf: iTs)
        row.append(contentsOf: u)
        row.append(contentsOf: k)
        row.append(contentsOf: e)
        row.append(contentsOf: n)
        row.append(contentsOf: g)
        row.append(contentsOf: shShhZ)
        row.append(contentsOf: x)
        return row
    }

    static var qazaqSecondRow: InputSet.Row {
        let f: [InputSet.Item] = InputSet.Row(chars: "ф")
        let i: [InputSet.Item] = [InputSet.Item("ы", hidden: InputSet.Item("і"))]
        let v: [InputSet.Item] = InputSet.Row(chars: "в")

        let a: [InputSet.Item] = [InputSet.Item("а", hidden: InputSet.Item("ә"))]
        let pr = InputSet.Row(chars: "пр")
        let o: [InputSet.Item] = [InputSet.Item("о", hidden: InputSet.Item("ө"))]
        let ldzhz: [InputSet.Item] = InputSet.Row(chars: "лджэ")

        return f + i + v + a + pr + o + ldzhz
    }

    static var qazaqThirdRow: InputSet.Row {
        let yaChSM: [InputSet.Item] = InputSet.Row(chars: "ячсм")
        let i = [InputSet.Item("и", hidden: InputSet.Item("і"))]
        let t: [InputSet.Item] = InputSet.Row(chars: "т")
        let easyMarkHehe = [InputSet.Item("ь", hidden: InputSet.Item("ъ"))]
        let byu: [InputSet.Item] = InputSet.Row(chars: "бю")
        return yaChSM + i + t + easyMarkHehe + byu
    }

    static var russianThirdRow: InputSet.Row {
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
