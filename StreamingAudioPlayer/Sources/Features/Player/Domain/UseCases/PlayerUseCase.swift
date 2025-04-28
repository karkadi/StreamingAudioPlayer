//
//  PlayerUseCase.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Features/Player/Domain/UseCases/PlayerUseCase.swift
import Foundation

/// Use case for player actions.
final class PlayerUseCase {
    private let repository: PlayerRepositoryProtocol

    init(repository: PlayerRepositoryProtocol) {
        self.repository = repository
    }

    func play(station: RadioStationEntity) async throws {
        try await repository.play(station: station)
    }

    func pause() async {
        await repository.pause()
    }

    func stop() async {
        await repository.stop()
    }
}
