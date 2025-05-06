//
//  RadioStationEntity.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Features/Home/Domain/Entities/RadioStationEntity.swift
import Foundation
import AppIntents

/// Entity for radio station in domain layer.
struct RadioStationEntity: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let streamURL: URL
}
