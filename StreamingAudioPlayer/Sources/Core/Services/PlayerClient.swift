//
//  PlayerClient.swift
//  TCATestApp
//
//  Created by Arkadiy KAZAZYAN on 27/05/2025.
//
import ComposableArchitecture

// MARK: - Protocol
struct PlayerClient: Sendable {
    var play: @Sendable (_ station: RadioStationEntity) async throws -> Void
    var pause: @Sendable() async -> Void
    var stop: @Sendable() async -> Void
}

// MARK: - Live Implementation
extension PlayerClient: DependencyKey {
    static let liveValue: PlayerClient = {
        return PlayerClient(
            play: { station in
                try await AudioService.shared.play(station: station)
            },
            pause: {
                await AudioService.shared.pause()
            },
            stop: {
                await AudioService.shared.stop()
            }
        )
    }()
}

// MARK: - Dependency Registration
extension DependencyValues {
    var playerClient: PlayerClient {
        get { self[PlayerClient.self] }
        set { self[PlayerClient.self] = newValue }
    }
}
