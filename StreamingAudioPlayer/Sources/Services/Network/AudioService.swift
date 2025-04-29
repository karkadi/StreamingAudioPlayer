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

/// Service for streaming audio using AVPlayer with background playback support.
final class AudioService {
    private let player = AVPlayer()
    private let logger = Logger(subsystem: "com.example.RadioStreaming", category: "AudioService")
    private let audioSession = AVAudioSession.sharedInstance()

    init() {
        Task { await setupAudioSession() }
    }

    /// Configures the audio session for background playback.
    @MainActor
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [])
            try audioSession.setActive(true)
            logger.info("Audio session configured for background playback")
        } catch {
            logger.error("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

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

    /// Stops playback and deactivates the audio session.
    @MainActor
    func stop() {
        player.replaceCurrentItem(with: nil)
        do {
            try audioSession.setActive(false)
            logger.info("Stopped audio and deactivated audio session")
        } catch {
            logger.error("Failed to deactivate audio session: \(error.localizedDescription)")
        }
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
