//
//  RadioStation.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Models/RadioStation.swift
import Foundation

/// A model representing a radio station with streaming details.
@Observable
final class RadioStation: Identifiable, Codable {
    let id: UUID
    let name: String
    let streamURL: URL

    init(id: UUID = UUID(), name: String, streamURL: URL) {
        self.id = id
        self.name = name
        self.streamURL = streamURL
    }
}
