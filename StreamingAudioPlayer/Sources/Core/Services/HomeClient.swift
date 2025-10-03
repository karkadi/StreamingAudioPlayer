//
//  HomeClient.swift
//  TCATestApp
//
//  Created by Arkadiy KAZAZYAN on 27/05/2025.
//
import ComposableArchitecture
import Foundation
import UIKit
import OSLog

// MARK: - Protocol
struct HomeClient: Sendable {
    var fetchStations: @Sendable() async throws -> [RadioStationEntity]
}

// MARK: - Live Implementation
extension HomeClient: DependencyKey {
    static let liveValue: HomeClient = {
        let logger = Logger(subsystem: "karkadi.com.StreamingAudioPlayer", category: "HomeClient")
        
        return HomeClient(
            fetchStations: {
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
        )
    }()
}

// MARK: - Dependency Registration
extension DependencyValues {
    var homeClient: HomeClient {
        get { self[HomeClient.self] }
        set { self[HomeClient.self] = newValue }
    }
}
