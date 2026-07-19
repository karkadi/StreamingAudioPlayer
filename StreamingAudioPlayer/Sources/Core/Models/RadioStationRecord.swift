//
//  RadioStationRecord.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 19/07/2026.
//

import Foundation
import SwiftData

/// SwiftData persistence model for a radio station.
///
/// `RadioStationEntity` stays a plain, `Sendable`/`Equatable`/`Hashable`
/// struct so it keeps working everywhere it's used today (TCA state, views,
/// `UserDefaults` persistence). This `@Model` class is only responsible for
/// storing that data in SwiftData, and knows how to convert both ways.
@Model
final class RadioStationRecord {
    @Attribute(.unique) var id: Int
    var name: String
    var imagrUrl: URL
    var streamURL: URL

    init(id: Int, name: String, imagrUrl: URL, streamURL: URL) {
        self.id = id
        self.name = name
        self.imagrUrl = imagrUrl
        self.streamURL = streamURL
    }

    convenience init(entity: RadioStationEntity) {
        self.init(
            id: entity.id,
            name: entity.name,
            imagrUrl: entity.imagrUrl,
            streamURL: entity.streamURL
        )
    }

    /// Maps back to the domain-layer entity used throughout the app.
    var asEntity: RadioStationEntity {
        RadioStationEntity(id: id, name: name, imagrUrl: imagrUrl, streamURL: streamURL)
    }
}
