//
//  HomeDataSource.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Features/Home/Data/DataSources/HomeDataSource.swift
import Foundation

/// Mock data source for radio stations.
final class HomeDataSource {
    func fetchStations() async -> [RadioStationEntity] {
        // Mocked data
        [
            RadioStationEntity(id: UUID(), name: "France Inter", streamURL: URL(string: "https://icecast.radiofrance.fr/franceinter-hifi.aac")!),
            RadioStationEntity(id: UUID(), name: "France Culture", streamURL: URL(string: "https://icecast.radiofrance.fr/franceculture-hifi.aac")!),
            RadioStationEntity(id: UUID(), name: "Радио 1.FM", streamURL: URL(string: "https://strm112.1.fm/top40_mobile_mp3")!),
            RadioStationEntity(id: UUID(), name: "Радио Романтика", streamURL: URL(string: "https://pub0201.101.ru/stream/air/aac/64/101")!),
        ]
    }
}
