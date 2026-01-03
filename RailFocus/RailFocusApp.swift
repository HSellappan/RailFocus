//
//  RailFocusApp.swift
//  RailFocus
//
//  Created by Harold S on 1/3/26.
//

import SwiftUI

@main
struct RailFocusApp: App {
    @State private var appState = AppState()
    @State private var theme = Theme.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appState, appState)
                .environment(\.theme, theme)
        }
    }
}
