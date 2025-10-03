//
//  AboutClient.swift
//  TCATestApp
//
//  Created by Arkadiy KAZAZYAN on 27/05/2025.
//
import ComposableArchitecture

// MARK: - Dependency Keys
enum AboutClient: DependencyKey {
    static let liveValue = AboutInfoModel(
        appName: "StreamingAudioPlayer",
        creator: "Arkadiy KAZAZYAN",
        creationDate: "May 29, 2025"
    )
}

// MARK: - Dependency Registration
extension DependencyValues {
    var aboutClient: AboutInfoModel {
        self[AboutClient.self]
    }
}
