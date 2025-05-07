//
//  AboutUseCase.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 09/04/2025.
//

// Domain Layer: Use Case Protocol
protocol AboutUseCase {
    func fetchAboutInfo() -> AboutInfoEntity
}

// Domain Layer: Default Implementation (for static data)
struct DefaultAboutUseCase: AboutUseCase {
    func fetchAboutInfo() -> AboutInfoEntity {
        AboutInfoEntity(
            appName: "StreamingAudioPlayer",
            creator: "Arkadiy KAZAZYAN",
            creationDate: "May 7, 2025"
        )
    }
}
