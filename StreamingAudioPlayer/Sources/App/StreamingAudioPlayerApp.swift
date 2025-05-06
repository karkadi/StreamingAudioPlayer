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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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

class AppDelegate: NSObject, UIApplicationDelegate {

    func applicationWillTerminate(_ application: UIApplication) {
        LiveActivityManager.shared.stopSessionTimeoutAsync()
    }

}
