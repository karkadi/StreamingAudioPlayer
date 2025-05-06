//
//  URL+Extensions.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 29/04/2025.
//

// Sources/Core/Extensions/URLExtensions.swift
import Foundation

extension URL {
    /// Checks if the URL is valid for streaming (has a scheme and is not a file URL).
    var isValidStreamingURL: Bool {
        guard let scheme = scheme, ["http", "https"].contains(scheme) else {
            return false
        }
        return !isFileURL
    }
}
