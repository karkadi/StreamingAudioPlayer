//
//  FavoriteUseCaseKey.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 08/05/2025.
//

import ComposableArchitecture
import Foundation

extension DependencyValues {
    var favoriteUseCase: FavoriteUseCase {
        get { self[FavoriteUseCaseKey.self] }
        set { self[FavoriteUseCaseKey.self] = newValue }
    }
}

private enum FavoriteUseCaseKey: DependencyKey {
    static let liveValue = FavoriteUseCase()
}
