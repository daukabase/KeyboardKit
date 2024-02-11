//
//  DemoLayoutProvider.swift
//  Keyboard
//
//  Created by Daniel Saidi on 2022-12-21.
//  Copyright © 2022-2023 Daniel Saidi. All rights reserved.
//

import KeyboardKit

/**
 This demo-specific provider inherits the standard one, then
 adds a rocket and a locale key around the space key.
 */
class DemoLayoutProvider: StandardKeyboardLayoutProvider {
    override init(
        baseProvider: KeyboardLayoutProvider = NeoQazaqKeyboardLayoutProvider(),
        localizedProviders: [StandardKeyboardLayoutProvider.LocalizedProvider] = []
    ) {
        super.init(baseProvider: baseProvider, localizedProviders: localizedProviders)
    }
}

private extension KeyboardLayout {
    func tryInsertEmojiButton() {
        guard let button = tryCreateBottomRowItem(for:  .keyboardType(.emojis)) else { return }
        itemRows.insert(button, before: .space, atRow: bottomRowIndex)
    }
}
