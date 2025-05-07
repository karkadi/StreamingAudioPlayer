//
//  LaunchScreenUseCase.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 06/04/2025.
//

protocol LaunchScreenUseCase {
    func goToScreen(to screen: LaunchScreenEntity) -> LaunchScreenEntity
}

class DefaultLaunchScreenUseCase: LaunchScreenUseCase {
    func goToScreen(to screen: LaunchScreenEntity) -> LaunchScreenEntity {
        screen
    }
}
