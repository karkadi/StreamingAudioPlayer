//
//  LiveActivityManager.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 05/05/2025.
//
import ActivityKit
import Foundation
import OSLog

final class LiveActivityManager {
    // MARK: - Singletone
    static let shared = LiveActivityManager()
    private let logger = Logger(subsystem: "karkadi.com.StreamingAudioPlayer", category: "LiveActivityManager")

    // MARK: - Initializers
    private init() { }

    func stopSessionTimeoutAsync()  {
        logger.info("Ending Live Activities")
        let semaphore = DispatchSemaphore(value: 0)
        Task {
            for activity in Activity<RadioLiveActivityAttributes>.activities {
                logger.info("Ending Live Activity: \(activity.id)")
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            semaphore.signal()
        }
        semaphore.wait()
    }

    @MainActor
    func startLiveActivity(station: String, isPlaying: Bool) async throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }
        let attributes = RadioLiveActivityAttributes(stationName: station)
        let contentState = RadioLiveActivityAttributes.ContentState(isPlaying: isPlaying)
        let content = ActivityContent(state: contentState, staleDate: nil)
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            logger.info("Live Activity started: \(activity.id)")
        } catch {
            logger.error("Failed to start Live Activity: \(error.localizedDescription)")
        }
    }

    @MainActor
    func updateLiveActivity( isPlaying: Bool) async {
        for activity in Activity<RadioLiveActivityAttributes>.activities {
            let contentState = RadioLiveActivityAttributes.ContentState(isPlaying: isPlaying)
            let content = ActivityContent(state: contentState, staleDate: nil)
            await activity.update(content)
        }
    }

    @MainActor
    func endLiveActivity() async {
        for activity in Activity<RadioLiveActivityAttributes>.activities {
            await activity.end( nil, dismissalPolicy: .immediate)
        }
    }
}
