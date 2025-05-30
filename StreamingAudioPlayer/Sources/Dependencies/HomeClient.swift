//
//  AboutClient.swift
//  TCATestApp
//
//  Created by Arkadiy KAZAZYAN on 27/05/2025.
//
import ComposableArchitecture
import Foundation
import UIKit
import OSLog

// MARK: - Protocol
protocol HomeClient {
    func fetchStations() async -> [RadioStationEntity]
}

// MARK: - Live Implementation
final class DefaultHomeClient: HomeClient {
    private let logger = Logger(subsystem: "karkadi.com.StreamingAudioPlayer", category: "HomeClient")
    func fetchStations() async -> [RadioStationEntity] {
        do {
            guard let asset = NSDataAsset(name: "RadioStations") else {
                logger.error("Missing data asset: RadioStations")
                return []
            }
            let stations = try JSONDecoder().decode([RadioStationEntity].self, from: asset.data)
            return stations
        } catch {
            logger.error("Error loading or decoding RadioStations.json: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - Dependency Keys
enum HomeClientKey: DependencyKey {
    static let liveValue: any HomeClient = DefaultHomeClient()
}

// MARK: - Dependency Registration
extension DependencyValues {
    var homeClient: any HomeClient {
        get { self[HomeClientKey.self] }
        set { self[HomeClientKey.self] = newValue }
    }
}
