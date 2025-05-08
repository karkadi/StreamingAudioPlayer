//
//  DatabaseServiceKey.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 18/03/2025.
//

import ComposableArchitecture
import SwiftData

// MARK: - Dependency Keys

enum DatabaseServiceKey: DependencyKey {
    static let liveValue: any DatabaseService = {
        do {
            let container = try ModelContainer(for: FavoriteStation.self)
            return SwiftDataService(modelContainer: container)
        } catch {
            fatalError("Failed to create test DatabaseService: \(error.localizedDescription)")
        }
    }()
    static let testValue: any DatabaseService = liveValue
    static let previewValue: any DatabaseService = liveValue
}

// MARK: - Dependency Registration
extension DependencyValues {
    var databaseService: any DatabaseService {
        get { self[DatabaseServiceKey.self] }
        set { self[DatabaseServiceKey.self] = newValue }
    }
}
