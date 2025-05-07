//
//  AboutUseCaseKey.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 09/04/2025.
//

import ComposableArchitecture

// MARK: - Dependency Keys
enum AboutUseCaseKey: DependencyKey {
    static let liveValue: any AboutUseCase = DefaultAboutUseCase()
    static let testValue: any AboutUseCase = DefaultAboutUseCase()
    static let previewValue: any AboutUseCase = DefaultAboutUseCase()
}

// MARK: - Dependency Registration
extension DependencyValues {
    var aboutUseCase: any AboutUseCase {
        get { self[AboutUseCaseKey.self] }
        set { self[AboutUseCaseKey.self] = newValue }
    }
}
