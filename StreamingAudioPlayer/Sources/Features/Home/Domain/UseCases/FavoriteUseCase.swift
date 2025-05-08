//
//  FavoriteUseCase.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 08/05/2025.
//

import ComposableArchitecture

/// Use case for managing favorite stations.
class FavoriteUseCase {
    @Dependency(\.databaseService) private var databaseService

    func addFavorite(stationId: Int) async throws {
        try await databaseService.addFavorite(stationId: stationId)
    }

    func removeFavorite(stationId: Int) async throws {
        try await databaseService.removeFavorite(stationId: stationId)
    }

    func getFavoriteStationIds() async throws -> [Int] {
        try await databaseService.getFavoriteStationIds()
    }

    func isFavorite(stationId: Int) async throws -> Bool {
        try await databaseService.isFavorite(stationId: stationId)
    }
}
