//
//  PlayerUseCaseKey.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 01/05/2025.
//

import ComposableArchitecture
import Foundation

extension DependencyValues {
    var playerUseCase: PlayerUseCase {
        get { self[PlayerUseCaseKey.self] }
        set { self[PlayerUseCaseKey.self] = newValue }
    }
}

private enum PlayerUseCaseKey: DependencyKey {
    static let liveValue = PlayerUseCase(
        repository: PlayerRepository(audioService: AudioService())
    )
}
