//
//  HomeUseCaseKey.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import ComposableArchitecture
import Foundation

extension DependencyValues {
    var homeUseCase: HomeUseCase {
        get { self[HomeUseCaseKey.self] }
        set { self[HomeUseCaseKey.self] = newValue }
    }
}

private enum HomeUseCaseKey: DependencyKey {
    static let liveValue = HomeUseCase(
        repository: HomeRepository(dataSource: HomeDataSource())
    )
}


