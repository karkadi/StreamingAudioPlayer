//
//  AudioStateObserver.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 07/05/2025.
//

import Combine
import Observation
import Foundation

@Observable
class AudioStateObserver {
    var isPlaying: Bool = false
    var currentStationName: String?
    var currentStationUrl: String?

    private var observationTask: Task<Void, Never>?
    private let userDefaults = UserDefaults.appGroup

    init() {
        // Initial state
        isPlaying = userDefaults.bool(forKey: UserDefaultKey.isAudioPlaying)
        currentStationName = userDefaults.string(forKey: UserDefaultKey.currentStationName)
        currentStationUrl = userDefaults.string(forKey: UserDefaultKey.currentStationUrl)

        // Observe changes
        observationTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: UserDefaults.didChangeNotification) {
                guard let self = self else { return }
                self.isPlaying = self.userDefaults.bool(forKey: UserDefaultKey.isAudioPlaying)
                self.currentStationName = self.userDefaults.string(forKey: UserDefaultKey.currentStationName)
                self.currentStationUrl = self.userDefaults.string(forKey: UserDefaultKey.currentStationUrl)
            }
        }
    }

    deinit {
        observationTask?.cancel()
    }
}
