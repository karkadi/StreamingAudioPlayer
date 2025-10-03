//
//  FavoriteStation.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 08/05/2025.
//

import SwiftData

/// A SwiftData model to store favorite station IDs.
@Model
class FavoriteStation {
    @Attribute(.unique) var id: Int

    init(id: Int) {
        self.id = id
    }
}
