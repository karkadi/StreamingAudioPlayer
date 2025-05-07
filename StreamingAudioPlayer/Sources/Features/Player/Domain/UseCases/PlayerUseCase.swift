//
//  PlayerUseCase.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import Foundation
import ActivityKit

protocol PlayerUseCaseProtocol {
    func play(station: RadioStationEntity) async throws
    func pause() async
    func stop() async
}

final class PlayerUseCase: PlayerUseCaseProtocol {
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
