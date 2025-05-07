//
//  HomeRepository.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import Foundation

/// Protocol for fetching radio stations.
protocol HomeRepositoryProtocol {
    func fetchStations() async throws -> [RadioStationEntity]
}

/// Repository for fetching radio stations.
final class HomeRepository: HomeRepositoryProtocol {
    private let dataSource: HomeDataSource

    init(dataSource: HomeDataSource) {
        self.dataSource = dataSource
    }

    func fetchStations() async throws -> [RadioStationEntity] {
        await dataSource.fetchStations()
    }
}
