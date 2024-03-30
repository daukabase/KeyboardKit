//
//  HomeScreen.swift
//  KeyboardKit
//
//  Created by Daniel Saidi on 2021-02-11.
//  Copyright © 2021-2024 Daniel Saidi. All rights reserved.
//

import KeyboardKitPro
import SwiftUI

/// This is the main demo app screen.
///
/// The screen shows keyboard-specific states and has a text
/// field, an appearance toggle and some settings.
struct HomeScreen: View {

    @State
    private var appearance = ColorScheme.light

    @State
    private var isAppearanceDark = false

    @AppStorage("com.keyboardkit.demo.text")
    private var text = ""

    @StateObject
    private var dictationContext = DictationContext(config: .app)

    @StateObject
    private var keyboardStatus = KeyboardStatusContext(
        bundleId: "com.keyboardkit.demo.*")

    var body: some View {
        NavigationView {
            List {
                textFieldSection
                editorLinkSection
                stateSection
            }
            .buttonStyle(.plain)
            .navigationTitle("KeyboardKit")
            .onChange(of: isAppearanceDark) { newValue in
                appearance = isAppearanceDark ? .dark : .light
            }
        }
        .navigationViewStyle(.stack)
        .keyboardDictation(
            context: dictationContext,
            config: .app,
            speechRecognizer: StandardSpeechRecognizer()
        ) {
            Dictation.Screen(
                dictationContext: dictationContext) {
                    EmptyView()
                } indicator: {
                    Dictation.BarVisualizer(isAnimating: $0)
                } doneButton: { action in
                    Button("Done", action: action)
                        .buttonStyle(.borderedProminent)
                }
        }
    }
}

extension HomeScreen {

    var textFieldSection: some View {
        Section(header: Text("Text Field")) {
            TextEditor(text: $text)
                .frame(height: 100)
                .keyboardAppearance(appearance)
                .environment(\.layoutDirection, isRtl ? .rightToLeft : .leftToRight)
            Toggle(isOn: $isAppearanceDark) {
                Text("Dark appearance")
            }
        }
    }

    var editorLinkSection: some View {
        Section(header: Text("Editor")) {
            NavigationLink {
                TextEditor(text: $text)
                    .padding(.horizontal)
                    .navigationTitle("Editor")
            } label: {
                Label {
                    Text("Full screen editor")
                } icon: {
                    Image(systemName: "doc.text")
                }
            }
        }
    }

    var stateSection: some View {
        Section(header: Text("Keyboard"), footer: footerText) {
            KeyboardStatusLabel(
                isEnabled: keyboardStatus.isKeyboardActive,
                enabledText: "Demo keyboard is active",
                disabledText: "Demo keyboard is not active"
            )
            KeyboardSettings.Link(addNavigationArrow: true) {
                KeyboardStatus.Label(
                    isEnabled: keyboardStatus.isKeyboardEnabled,
                    enabledText: "Demo keyboard is enabled",
                    disabledText: "Demo keyboard not enabled"
                )
            }
            KeyboardSettings.Link(addNavigationArrow: true) {
                KeyboardStatus.Label(
                    isEnabled: keyboardStatus.isFullAccessEnabled,
                    enabledText: "Full Access is enabled",
                    disabledText: "Full Access is disabled"
                )
            }
        }
    }
    
    var footerText: some View {
        Text("You must enable the keyboard in System Settings, then select it with 🌐 when typing.")
    }

    var isRtl: Bool {
        let keyboardId = keyboardStatus.activeKeyboardBundleIds.first
        return keyboardId?.hasSuffix("rtl") ?? false
    }
}

#Preview {
    
    HomeScreen()
}
