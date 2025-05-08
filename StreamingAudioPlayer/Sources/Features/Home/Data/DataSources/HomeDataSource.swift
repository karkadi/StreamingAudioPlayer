//
//  HomeDataSource.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import Foundation

/// Mock data source for radio stations.
final class HomeDataSource {
    func fetchStations() async -> [RadioStationEntity] {
        // Mocked data
        [
            RadioStationEntity(id: 1,
                               name: "France Inter",
                               imagrUrl: URL(string:"https://cdn.instant.audio/images/logos/ecouterradioenligne-com/france-inter.png")!,
                               streamURL: URL(string: "https://icecast.radiofrance.fr/franceinter-hifi.aac")!),
            RadioStationEntity(id: 2,
                               name: "France Culture",
                               imagrUrl: URL(string:"https://cdn.instant.audio/images/logos/ecouterradioenligne-com/france-culture.png")!,
                               streamURL: URL(string: "https://icecast.radiofrance.fr/franceculture-hifi.aac")!),
            RadioStationEntity(id: 3,
                               name: "Радио 1.FM",
                               imagrUrl: URL(string:"https://radiopotok.ru/f/station/512/38.png")!,
                               streamURL: URL(string: "https://strm112.1.fm/top40_mobile_mp3")!),
            RadioStationEntity(id: 4,
                               name: "Радио Романтика",
                               imagrUrl: URL(string:"https://radiopotok.ru/f/station/512/177.png")!,
                               streamURL: URL(string: "https://pub0201.101.ru/stream/air/aac/64/101")!),
        ]
    }
}
