//
//  ReffectApp.swift
//  Reffect
//

import SwiftUI

@main
struct ReffectApp: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            BoardListView()
                .environment(store)
        }
    }
}
