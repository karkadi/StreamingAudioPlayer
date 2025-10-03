//
//  AudioService.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import AVKit
import Foundation
import OSLog
import MediaPlayer
import CachedAsyncImage

/// Service for streaming audio using AVPlayer with background playback and Now Playing support.
@MainActor
final class AudioService {
    // MARK: - Singleton

    static let shared = AudioService()
    private let player = AVPlayer()
    private let logger = Logger(subsystem: "karkadi.com.StreamingAudioPlayer", category: "AudioService")
    private var state: State = .disabled {
        didSet {
            // Save playing state to UserDefaults whenever it changes
            UserDefaults.appGroup.set(state == .playing, forKey: UserDefaultKey.isAudioPlaying)
            Task { await updateNowPlayingInfo() }
        }
    }
    
    private enum State {
        case playing
        case paused
        case stopped
        case disabled
    }
    
    init() {
        Task {
            setupAudioSession()
        }
    }
    
    var isEnabled: Bool {
        state != .disabled
    }
    
    var isPlaying: Bool {
        state == .playing
    }
    
    /// Configures the audio session and remote command center for background playback.
    @MainActor
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
            state = .stopped
            logger.info("Audio session configured for background playback")
            setupRemoteCommandCenter()
        } catch {
            state = .disabled
            logger.error("Failed to configure audio session: \(error.localizedDescription)")
        }
    }
    
    /// Sets up the remote command center for lock screen/control center controls.
    @MainActor
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self, state == .paused else { return .commandFailed }
            Task {
                await self.resumePlayback()
            }
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self, state == .playing else { return .commandFailed }
            Task {
                await self.pause()
            }
            return .success
        }
    }
    
    /// Resumes playback (used by remote commands).
    @MainActor
    private func resumePlayback() async {
        if let entry = RadioStationEntity.loadStruct() {
            do {
                try await play(station: entry)
            } catch {
                logger.error("Failed to resume playback: \(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the Now Playing info for the lock screen/control center.
    @MainActor
    private func updateNowPlayingInfo() async {
        var nowPlayingInfo = [String: Any]()
        if state == .playing || state == .paused {
            if let entry = RadioStationEntity.loadStruct() {
                nowPlayingInfo[MPMediaItemPropertyTitle] = entry.name
                nowPlayingInfo[MPMediaItemPropertyMediaType] = MPMediaType.anyAudio.rawValue
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = state == .playing ? 1.0 : 0.0
                nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0.0
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = 0.0
                
                if let image = ImageCache().wrappedValue[entry.imagrUrl] {
                    let artwork = MPMediaItemArtwork.init(boundsSize: image.size,
                                                          requestHandler: { @Sendable _ -> UIImage in image })
                    nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
                    MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
                }
            }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo.isEmpty ? nil : nowPlayingInfo
    }
    
    /// Plays audio for a station.
    @MainActor
    func play(station: RadioStationEntity) async throws {
        guard station.streamURL.isValidStreamingURL else {
            logger.error("Invalid streaming URL: \(station.streamURL.absoluteString)")
            throw AudioError.invalidURL
        }
        let playerItem = AVPlayerItem(url: station.streamURL)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        try await Task.sleep(for: .seconds(1)) // Wait for 1 second
        state = .playing
        logger.info("Playing audio from \(station.streamURL.absoluteString)")
        station.saveStruct()
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
        UserDefaults.appGroup.removeObject(forKey: UserDefaultKey.radioStationEntity)
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
