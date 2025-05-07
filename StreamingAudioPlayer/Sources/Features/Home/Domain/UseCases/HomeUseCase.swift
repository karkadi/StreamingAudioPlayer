//
//  HomeUseCase.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import Foundation

/// Use case for fetching radio stations.
final class HomeUseCase {
    private let repository: HomeRepositoryProtocol

    init(repository: HomeRepositoryProtocol) {
        self.repository = repository
    }

    func fetchStations() async throws -> [RadioStationEntity] {
        try await repository.fetchStations()
    }
}
