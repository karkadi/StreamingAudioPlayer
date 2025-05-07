//
//  RadioStationEntity.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import Foundation

/// Entity for radio station in domain layer.
struct RadioStationEntity: Identifiable, Equatable, Hashable {
    let id: UUID
    let name: String
    let imagrUrl: URL
    let streamURL: URL
}
