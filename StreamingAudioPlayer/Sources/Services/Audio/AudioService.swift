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
    // MARK: - Singletone
    static let shared = AudioService()
    private let player = AVPlayer()
    private let logger = Logger(subsystem: "karkadi.com.StreamingAudioPlayer", category: "AudioService")
    private var state: State = .disabled

    private enum State {
        case playing
        case paused
        case stopped
        case disabled
    }

    init() {
        Task {
            await setupAudioSession()
        }
    }

    var isEnabled: Bool {
        state != .disabled
    }

    var isPlaying: Bool {
        state == .playing
    }

    /// Configures the audio session for background playback.
    @MainActor
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            state = .stopped
            logger.info("Audio session configured for background playback")
        } catch {
            state = .disabled
            logger.error("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    /// Plays audio from a URL.
    @MainActor
    func play(station: String, url: URL) async throws {
        guard url.isValidStreamingURL else {
            logger.error("Invalid streaming URL: \(url.absoluteString)")
            throw AudioError.invalidURL
        }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        state = .playing
        logger.info("Playing audio from \(url.absoluteString)")

    }
    
    /// Pauses playback.
    @MainActor
    func pause() async {
        player.pause()
        state = .paused
        logger.info("Paused audio")

    }
    
    /// Stops playback and deactivates the audio session.
    @MainActor
    func stop() async {
        player.replaceCurrentItem(with: nil)
        do {
            try AVAudioSession.sharedInstance().setActive(false)
            state = .stopped
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
