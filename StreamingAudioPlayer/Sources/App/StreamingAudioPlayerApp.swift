//
//  StreamingAudioPlayerApp.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import SwiftUI
import CachedAsyncImage

@main
struct StreamingAudioPlayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            LaunchScreenView()
                .preferredColorScheme(.dark)
        }
    }

    init() {
        // Set image cache limit.
        ImageCache().wrappedValue.setCacheLimit(
            countLimit: 1_000, // 1000 items
            totalCostLimit: 1_024 * 1_024 * 200 // 200 MB
        )
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {

    func applicationWillTerminate(_ application: UIApplication) {
        LiveActivityManager.shared.stopSessionTimeoutAsync()
    }

}
