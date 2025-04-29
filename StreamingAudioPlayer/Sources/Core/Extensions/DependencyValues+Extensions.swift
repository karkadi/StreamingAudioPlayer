//
//  DependencyValues+Extensions.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Core/Extensions/DependencyValues+Extensions.swift
import ComposableArchitecture
import Foundation

extension DependencyValues {
    var homeUseCase: HomeUseCase {
        get { self[HomeUseCaseKey.self] }
        set { self[HomeUseCaseKey.self] = newValue }
    }

    var playerUseCase: PlayerUseCase {
        get { self[PlayerUseCaseKey.self] }
        set { self[PlayerUseCaseKey.self] = newValue }
    }
}

private enum HomeUseCaseKey: DependencyKey {
    static let liveValue = HomeUseCase(
        repository: HomeRepository(dataSource: HomeDataSource())
    )
}

private enum PlayerUseCaseKey: DependencyKey {
    static let liveValue = PlayerUseCase(
        repository: PlayerRepository(audioService: AudioService())
    )
}
