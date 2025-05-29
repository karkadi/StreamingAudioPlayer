//
//  PlayerClient.swift
//  TCATestApp
//
//  Created by Arkadiy KAZAZYAN on 27/05/2025.
//
import ComposableArchitecture

// MARK: - Protocol
protocol PlayerClient {
    func play(station: RadioStationEntity) async throws
    func pause() async
    func stop() async
}

// MARK: - Live Implementation
class DefaultPlayerClient: PlayerClient {
    func play(station: RadioStationEntity) async throws {
        try await AudioService.shared.play(station: station)
    }

    func pause() async {
        await AudioService.shared.pause()
    }

    func stop() async {
        await AudioService.shared.stop()
    }
}

// MARK: - Dependency Keys
enum PlayerClientKey: DependencyKey {
    static let liveValue: any PlayerClient = DefaultPlayerClient()
}

// MARK: - Dependency Registration
extension DependencyValues {
    var playerClient: any PlayerClient {
        get { self[PlayerClientKey.self] }
        set { self[PlayerClientKey.self] = newValue }
    }
}

