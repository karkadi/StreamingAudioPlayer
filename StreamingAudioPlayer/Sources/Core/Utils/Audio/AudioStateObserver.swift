//
//  AudioStateObserver.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 07/05/2025.
//

import Combine
import Observation
import Foundation

@MainActor
@Observable
class AudioStateObserver {
    var isPlaying: Bool = false
    var radioStationEntity: RadioStationEntity?

    private var observationTask: Task<Void, Never>?
    private let userDefaults = UserDefaults.appGroup

    init() {
        // Initial state
        isPlaying = userDefaults.bool(forKey: UserDefaultKey.isAudioPlaying)
        radioStationEntity = RadioStationEntity.loadStruct()

        // Observe changes
        observationTask = Task { [weak self] in
            for await _ in NotificationCenter.default.notifications(named: UserDefaults.didChangeNotification) {
                guard let self = self else { return }
                self.isPlaying = self.userDefaults.bool(forKey: UserDefaultKey.isAudioPlaying)
                self.radioStationEntity = RadioStationEntity.loadStruct()
            }
        }
    }
    @MainActor
    deinit {
        observationTask?.cancel()
    }
}
