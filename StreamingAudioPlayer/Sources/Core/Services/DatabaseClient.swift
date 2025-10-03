//
//  DatabaseClient.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 18/03/2025.
//
import Dependencies
import Foundation
import SwiftData

// MARK: - Sendable Service
struct DatabaseClient: Sendable {
    var addFavorite: @Sendable (_ stationId: Int) async throws -> Void
    var removeFavorite: @Sendable (_ stationId: Int) async throws -> Void
    var getFavoriteStationIds: @Sendable () async throws -> [Int]
    var isFavorite: @Sendable (_ stationId: Int) async throws -> Bool
}

// MARK: - Dependency Registration
extension DependencyValues {
    var databaseClient: DatabaseClient {
        get { self[DatabaseClient.self] }
        set { self[DatabaseClient.self] = newValue }
    }
}

#if true
actor SwiftDataActor {
    private let modelContext: ModelContext
    
    init(container: ModelContainer) {
        self.modelContext = ModelContext(container)
    }
    
    enum DatabaseError: Error {
        case saveFailed
    }
    
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
    
}
// MARK: - Live Value
extension DatabaseClient: DependencyKey {
    static let liveValue: DatabaseClient = {
        do {
            let schema = Schema([ FavoriteStation.self])
            let config = ModelConfiguration(schema: schema)
            let container = try ModelContainer(for: schema, configurations: config)
            let actor = SwiftDataActor(container: container)
            
            return DatabaseClient(
                addFavorite: { stationId in try await actor.addFavorite(stationId: stationId) },
                removeFavorite: { stationId in try await actor.removeFavorite(stationId: stationId) },
                getFavoriteStationIds: { try await actor.getFavoriteStationIds() },
                isFavorite: {stationId in try await actor.isFavorite(stationId: stationId) }
            )
        } catch {
            fatalError("Failed to create test DatabaseClient: \(error.localizedDescription)")
        }
    }()
}

#else

@MainActor
private func doAddFavorite(_ stationId: Int) async throws {
    @Dependency(\.modelContextProvider) var modelContextProvider
    let context = modelContextProvider.context()
    let favorite = FavoriteStation(id: stationId)
    context.insert(favorite)
    try context.save()
}

@MainActor
private func doRemoveFavorite(_ stationId: Int) async throws {
    @Dependency(\.modelContextProvider) var modelContextProvider
    let context = modelContextProvider.context()
    let predicate = #Predicate<FavoriteStation> { $0.id == stationId }
    let fetchDescriptor = FetchDescriptor<FavoriteStation>(predicate: predicate)
    if let favorite = try context.fetch(fetchDescriptor).first {
        context.delete(favorite)
        try context.save()
    }
}

@MainActor
private func doGetFavoriteStationIds() async throws -> [Int] {
    @Dependency(\.modelContextProvider) var modelContextProvider
    let context = modelContextProvider.context()
    let fetchDescriptor = FetchDescriptor<FavoriteStation>()
    let favorites = try context.fetch(fetchDescriptor)
    return favorites.map { $0.id }
}

@MainActor
private func doFavorite(_ stationId: Int) async throws -> Bool {
    @Dependency(\.modelContextProvider) var modelContextProvider
    let context = modelContextProvider.context()
    let predicate = #Predicate<FavoriteStation> { $0.id == stationId }
    let fetchDescriptor = FetchDescriptor<FavoriteStation>(predicate: predicate)
    return try context.fetchCount(fetchDescriptor) > 0
}

// MARK: - Live Value
extension DatabaseClient: DependencyKey {
    static let liveValue = Self(
        addFavorite: doAddFavorite,
        removeFavorite: doRemoveFavorite,
        getFavoriteStationIds: doGetFavoriteStationIds,
        isFavorite: doFavorite
    )
}
#endif
