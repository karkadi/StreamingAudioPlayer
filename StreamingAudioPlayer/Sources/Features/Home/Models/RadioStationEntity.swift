//
//  RadioStationEntity.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import Foundation
import OSLog

/// Entity for radio station in domain layer.
struct RadioStationEntity: Identifiable, Equatable, Hashable, Codable, Sendable {

    let id: Int
    let name: String
    let imagrUrl: URL
    let streamURL: URL

    // Save to UserDefaults
    @MainActor
    func saveStruct() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.appGroup.set(data, forKey: UserDefaultKey.radioStationEntity)
        } catch {
            Logger(subsystem: "karkadi.com.StreamingAudioPlayer", category: "RadioStationEntity").error("Error encoding struct: \(error)")
        }
    }

    // Load from UserDefaults
    @MainActor
    static func loadStruct() -> RadioStationEntity? {
        guard let data = UserDefaults.appGroup.data(forKey: UserDefaultKey.radioStationEntity) else { return nil }
        do {
            return try JSONDecoder().decode(RadioStationEntity.self, from: data)
        } catch {
            Logger(subsystem: "karkadi.com.StreamingAudioPlayer", category: "RadioStationEntity").error("Error decoding struct: \(error)")
            return nil
        }
    }
}
