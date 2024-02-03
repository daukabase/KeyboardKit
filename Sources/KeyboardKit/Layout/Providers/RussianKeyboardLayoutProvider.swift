//
//  RussianKeyboardLayoutProvider.swift
//
//
//  Created by Daulet Almagambetov on 02.02.2024.
//

import Foundation

public class NeoQazaqKeyboardLayoutProvider: InputSetBasedKeyboardLayoutProvider {
    public init() {
        super.init(
            alphabeticInputSet: .neoQazaq,
            numericInputSet: .standardNumeric(currency: "₽"),
            symbolicInputSet: .standardSymbolic(currencies: ["€", "$", "£"])
        )
        self.localeKey = KeyboardLocale.kazakh.id
    }
}

public class RussianKeyboardLayoutProvider: InputSetBasedKeyboardLayoutProvider {
    public init() {
        super.init(
            alphabeticInputSet: .russian,
            numericInputSet: .standardNumeric(currency: "₽"),
            symbolicInputSet: .standardSymbolic(currencies: ["€", "$", "£"])
        )
        self.localeKey = KeyboardLocale.russian.id
    }
}
