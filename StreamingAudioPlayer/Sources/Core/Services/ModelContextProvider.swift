//
//  ModelContextProvider.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 06/10/2025.
//

import Dependencies
import Foundation
import SwiftData

extension DependencyValues {
    public var modelContextProvider: ModelContextProvider {
        get { self[ModelContextKey.self] }
        set { self[ModelContextKey.self] = newValue }
    }
}

public struct ModelContextProvider: Sendable {
    let getContext: @Sendable @MainActor () -> ModelContext
    
    @MainActor
    public func context() -> ModelContext {
        getContext()
    }
}

public enum ModelContextKey: DependencyKey {
    public static let liveValue: ModelContextProvider = ModelContextProvider(
        getContext: { liveContainer.mainContext }
    )
}

/// Create a ModelContainer to be used in a live environment.
func makeLiveContainer(dbFile: URL) -> ModelContainer {
    print("dbFile:\(dbFile)")
    do {
        let schema = Schema([FavoriteStation.self])
        let config = ModelConfiguration(schema: schema)
        return try ModelContainer(for: schema, configurations: config)
    } catch {
        fatalError("Failed to create test DatabaseClient: \(error.localizedDescription)")
    }
}

private let liveContainer: ModelContainer = makeLiveContainer(
    dbFile: URL.applicationSupportDirectory.appending(path: "Models.sqlite")
)
