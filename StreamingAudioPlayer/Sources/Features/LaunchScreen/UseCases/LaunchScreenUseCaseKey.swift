//
//  LaunchScreenUseCaseKey.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 06/04/2025.
//

import ComposableArchitecture

// MARK: - Dependency Keys
enum LaunchScreenUseCaseKey: DependencyKey {
    static let liveValue: LaunchScreenUseCase = DefaultLaunchScreenUseCase()
    static let testValue: LaunchScreenUseCase = DefaultLaunchScreenUseCase()
    static let previewValue: LaunchScreenUseCase = DefaultLaunchScreenUseCase()
}

// MARK: - Dependency Registration
extension DependencyValues {
    var useCaseLaunchScreen: LaunchScreenUseCase {
        get { self[LaunchScreenUseCaseKey.self] }
        set { self[LaunchScreenUseCaseKey.self] = newValue }
    }
}
