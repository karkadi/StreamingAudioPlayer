//
//  AboutClient.swift
//  TCATestApp
//
//  Created by Arkadiy KAZAZYAN on 27/05/2025.
//
import ComposableArchitecture

// MARK: - Dependency Keys
enum AboutClientKey: DependencyKey {
    static let liveValue = AboutInfoModel(
        appName: "InstagramLikeApp",
        creator: "Arkadiy KAZAZYAN",
        creationDate: "April 10, 2025"
    )
}

// MARK: - Dependency Registration
extension DependencyValues {
    var aboutClient: AboutInfoModel {
        self[AboutClientKey.self]
    }
}
