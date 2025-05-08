//
//  SwiftDataService.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 14/03/2025.
//

import Foundation
import SwiftData

// sourcery: AutoMockable
protocol DatabaseService {
    func addFavorite(stationId: Int) async throws
    func removeFavorite(stationId: Int) async throws
    func getFavoriteStationIds() async throws -> [Int]
    func isFavorite(stationId: Int) async throws -> Bool
}

actor SwiftDataService: DatabaseService {

    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        self.modelContext = ModelContext(modelContainer)
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
