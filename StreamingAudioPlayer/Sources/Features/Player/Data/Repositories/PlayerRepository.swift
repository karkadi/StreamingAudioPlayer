//
//  PlayerRepository.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Features/Player/Data/Repositories/PlayerRepository.swift
import Foundation

/// Protocol for player actions.
protocol PlayerRepositoryProtocol {
    func play(station: RadioStationEntity) async throws
    func pause() async
    func stop() async
}

/// Repository for player actions.
final class PlayerRepository: PlayerRepositoryProtocol {
    private let audioService: AudioService

    init(audioService: AudioService) {
        self.audioService = audioService
    }

    func play(station: RadioStationEntity) async throws {
        try await audioService.play(url: station.streamURL)
    }

    func pause() async {
        await audioService.pause()
    }

    func stop() async {
        await audioService.stop()
    }
}
