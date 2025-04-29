//
//  AudioService.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Services/Network/AudioService.swift
import AVKit
import Foundation
import OSLog

/// Service for streaming audio using AVPlayer.
final class AudioService {
    private let player = AVPlayer()
    private let logger = Logger(subsystem: "com.example.RadioStreaming", category: "AudioService")

    /// Plays audio from a URL.
    @MainActor
    func play(url: URL) async throws {
        guard url.isValidStreamingURL else {
            logger.error("Invalid streaming URL: \(url.absoluteString)")
            throw AudioError.invalidURL
        }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        logger.info("Playing audio from \(url.absoluteString)")
    }

    /// Pauses playback.
    @MainActor
    func pause() {
        player.pause()
        logger.info("Paused audio")
    }

    /// Stops playback.
    @MainActor
    func stop() {
        player.replaceCurrentItem(with: nil)
        logger.info("Stopped audio")
    }
}

/// Error types for audio service.
enum AudioError: LocalizedError {
    case playbackFailed(Error)
    case invalidURL

    var errorDescription: String? {
        switch self {
        case .playbackFailed(let error):
            return "Playback failed: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid stream URL"
        }
    }
}
