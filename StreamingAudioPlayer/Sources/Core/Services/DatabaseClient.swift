//
//  DatabaseClient.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 18/03/2025.
//
import Dependencies
import Foundation
import OSLog
import SwiftData
import UIKit // NSDataAsset

// MARK: - Sendable Service
struct DatabaseClient: Sendable {
    // Favorites
    var addFavorite: @Sendable (_ stationId: Int) async throws -> Void
    var removeFavorite: @Sendable (_ stationId: Int) async throws -> Void
    var getFavoriteStationIds: @Sendable () async throws -> [Int]
    var isFavorite: @Sendable (_ stationId: Int) async throws -> Bool

    // Radio stations
    var addStation: @Sendable (_ station: RadioStationEntity) async throws -> Void
    var updateStation: @Sendable (_ station: RadioStationEntity) async throws -> Void
    var removeStation: @Sendable (_ stationId: Int) async throws -> Void
    var getAllStations: @Sendable () async throws -> [RadioStationEntity]

    /// Populates the store from the bundled `RadioStations.json` data asset
    /// the first time the store is empty. Safe to call on every launch.
    var seedStationsIfNeeded: @Sendable () async throws -> Void
}

// MARK: - Dependency Registration
extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}

actor SwiftDataActor {
    private let modelContext: ModelContext
    private let logger = Logger(subsystem: "karkadi.com.StreamingAudioPlayer", category: "SwiftDataActor")

    init(container: ModelContainer) {
        self.modelContext = ModelContext(container)
    }

    enum DatabaseError: Error {
        case saveFailed
        case stationNotFound
    }

    // MARK: - Favorites

    func addFavorite(stationId: Int) async throws {
        let favorite = FavoriteStation(id: stationId)
        modelContext.insert(favorite)
        try modelContext.save()
    }

    func removeFavorite(stationId: Int) async throws {
        let predicate = #Predicate<FavoriteStation> { $0.id == stationId }
        let fetchDescriptor = FetchDescriptor<FavoriteStation>(predicate: predicate)
        if let favorite = try modelContext.fetch(fetchDescriptor).first {
            modelContext.delete(favorite)
            try modelContext.save()
        }
    }

    func getFavoriteStationIds() async throws -> [Int] {
        let fetchDescriptor = FetchDescriptor<FavoriteStation>()
        let favorites = try modelContext.fetch(fetchDescriptor)
        return favorites.map { $0.id }
    }

    func isFavorite(stationId: Int) async throws -> Bool {
        let predicate = #Predicate<FavoriteStation> { $0.id == stationId }
        let fetchDescriptor = FetchDescriptor<FavoriteStation>(predicate: predicate)
        return try modelContext.fetchCount(fetchDescriptor) > 0
    }

    // MARK: - Radio stations

    /// Inserts a new station. If a station with the same id already exists,
    /// it's updated in place instead of creating a duplicate.
    func addStation(_ station: RadioStationEntity) async throws {
        if let existing = try fetchStationRecord(id: station.id) {
            apply(station, to: existing)
        } else {
            modelContext.insert(RadioStationRecord(entity: station))
        }
        try modelContext.save()
    }

    func updateStation(_ station: RadioStationEntity) async throws {
        guard let record = try fetchStationRecord(id: station.id) else {
            throw DatabaseError.stationNotFound
        }
        apply(station, to: record)
        try modelContext.save()
    }

    func removeStation(stationId: Int) async throws {
        if let record = try fetchStationRecord(id: stationId) {
            modelContext.delete(record)
            try modelContext.save()
        }
    }

    func getAllStations() async throws -> [RadioStationEntity] {
        let fetchDescriptor = FetchDescriptor<RadioStationRecord>(
            sortBy: [SortDescriptor(\.id)]
        )
        let records = try modelContext.fetch(fetchDescriptor)
        return records.map { $0.asEntity }
    }

    func seedStationsIfNeeded() async throws {
        let existingCount = try modelContext.fetchCount(FetchDescriptor<RadioStationRecord>())
        guard existingCount == 0 else { return }

        guard let asset = NSDataAsset(name: "RadioStations") else {
            logger.error("Missing data asset: RadioStations")
            return
        }

        do {
            let stations = try JSONDecoder().decode([RadioStationEntity].self, from: asset.data)
            for station in stations {
                modelContext.insert(RadioStationRecord(entity: station))
            }
            try modelContext.save()
            logger.info("Seeded \(stations.count) radio stations from RadioStations.json")
        } catch {
            logger.error("Error seeding RadioStations.json: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    private func fetchStationRecord(id: Int) throws -> RadioStationRecord? {
        let predicate = #Predicate<RadioStationRecord> { $0.id == id }
        let fetchDescriptor = FetchDescriptor<RadioStationRecord>(predicate: predicate)
        return try modelContext.fetch(fetchDescriptor).first
    }

    private func apply(_ station: RadioStationEntity, to record: RadioStationRecord) {
        record.name = station.name
        record.imagrUrl = station.imagrUrl
        record.streamURL = station.streamURL
    }
}

// MARK: - Live Value
extension DatabaseClient: DependencyKey {
    static let liveValue: DatabaseClient = {
        do {
            let schema = Schema([FavoriteStation.self, RadioStationRecord.self])
            let config = ModelConfiguration(schema: schema)
            let container = try ModelContainer(for: schema, configurations: config)
            let actor = SwiftDataActor(container: container)

            return DatabaseClient(
                addFavorite: { stationId in try await actor.addFavorite(stationId: stationId) },
                removeFavorite: { stationId in try await actor.removeFavorite(stationId: stationId) },
                getFavoriteStationIds: { try await actor.getFavoriteStationIds() },
                isFavorite: { stationId in try await actor.isFavorite(stationId: stationId) },
                addStation: { station in try await actor.addStation(station) },
                updateStation: { station in try await actor.updateStation(station) },
                removeStation: { stationId in try await actor.removeStation(stationId: stationId) },
                getAllStations: { try await actor.getAllStations() },
                seedStationsIfNeeded: { try await actor.seedStationsIfNeeded() }
            )
        } catch {
            fatalError("Failed to create live DatabaseClient: \(error.localizedDescription)")
        }
    }()
}
