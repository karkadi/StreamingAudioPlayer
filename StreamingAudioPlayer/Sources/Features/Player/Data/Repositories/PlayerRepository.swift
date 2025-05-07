//
//  PlayerRepository.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import Foundation

/// Protocol for player actions.
protocol PlayerRepositoryProtocol {
    func play(station: RadioStationEntity) async throws
    func pause() async
    func stop() async
}

/// Repository for player actions.
final class PlayerRepository: PlayerRepositoryProtocol {

    init(audioService: AudioService) {
    }

    func play(station: RadioStationEntity) async throws {
        await LiveActivityManager.shared.endLiveActivity()
        try await AudioService.shared.play(station: station.name, url: station.streamURL)
        try await LiveActivityManager.shared.startLiveActivity(station: station.name, isPlaying: true)
    }

    func pause() async {
        await AudioService.shared.pause()
        await LiveActivityManager.shared.endLiveActivity()
    }

    func stop() async {
        await AudioService.shared.stop()
        await LiveActivityManager.shared.endLiveActivity()
    }
}
