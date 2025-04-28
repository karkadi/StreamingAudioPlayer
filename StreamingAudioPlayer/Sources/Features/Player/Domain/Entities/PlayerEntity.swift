//
//  PlayerEntity.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Features/Player/Domain/Entities/PlayerEntity.swift
import Foundation

/// Entity for player state in domain layer.
struct PlayerEntity {
    let isPlaying: Bool
    let station: RadioStationEntity
}
