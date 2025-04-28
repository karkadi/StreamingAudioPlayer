//
//  StreamingAudioPlayerApp.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import SwiftUI
import ComposableArchitecture

@main
struct StreamingAudioPlayerApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView(
                store: Store(
                    initialState: HomeReducer.State(),
                    reducer: { HomeReducer() }
                )
            )
        }
    }
}
