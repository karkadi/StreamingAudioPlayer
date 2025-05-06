//
//  AudioControlIntent.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 01/05/2025.
//

import AppIntents
import OSLog
import ActivityKit

struct AudioControlIntent: AudioPlaybackIntent {

    private let logger = Logger(subsystem: "karkadi.com.StreamingAudioPlayer", category: "AudioControlIntent")

    init() {

    }

    init(action: AudioAction) {
        self.action = action
    }

    static var title: LocalizedStringResource = "Control Audio Playback"
    static var description = IntentDescription("Controls audio playback (play or stop).")

    // Define a parameter to specify the action (play or stop)
    @Parameter(title: "Action", optionsProvider: AudioActionOptionsProvider())
    var action: AudioAction

    // Options provider for the action parameter
    struct AudioActionOptionsProvider: DynamicOptionsProvider {
        func results() async throws -> [AudioAction] {
            [.play, .stop]
        }
    }

    // Enum to represent the action
    enum AudioAction: String, AppEnum {
        case play
        case stop

        static var typeDisplayRepresentation: TypeDisplayRepresentation = "Audio Action"
        static var caseDisplayRepresentations: [AudioAction: DisplayRepresentation] = [
            .play: "Play",
            .stop: "Stop"
        ]
    }

    // Perform the intent action
    func perform() async throws -> some IntentResult {
        logger.info("Performing action: \(action.rawValue)")
        switch action {
        case .play:
            // Example URL for playback (replace with your actual URL)
            let url = URL(string: "https://strm112.1.fm/top40_mobile_mp3")!
            try await AudioService.shared.play(station: "FM", url: url)
        case .stop:
            await AudioService.shared.pause()
            logger.info("Stop action executed")
            
        }
        // Update Live Activity state based on action
        if let activity = Activity<RadioLiveActivityAttributes>.activities.first {
            let contentState = RadioLiveActivityAttributes.ContentState(isPlaying: AudioService.shared.isPlaying)
            let content = ActivityContent(state: contentState, staleDate: nil)
            await activity.update(content)
        }

        UserDefaults.appGroup.set(
            AudioService.shared.isPlaying,
            forKey: UserDefaultKey.isAudioPlaying
        )
        return .result()
    }
}

// MARK: - PauseIntent

struct AudioPlaybackWidgetPauseIntent: AudioPlaybackIntent {
    static var title: LocalizedStringResource = "Pause Music"

    func perform() async throws -> some IntentResult {
        await AudioService.shared.pause()
        UserDefaults.appGroup.set(
            AudioService.shared.isPlaying,
            forKey: UserDefaultKey.isAudioPlaying
        )
        return .result()
    }
}
