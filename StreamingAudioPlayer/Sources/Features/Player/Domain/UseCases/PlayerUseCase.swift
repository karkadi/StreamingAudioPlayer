//
//  PlayerUseCase.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Features/Player/Domain/UseCases/PlayerUseCase.swift
import Foundation
import ActivityKit

protocol PlayerUseCaseProtocol {
    func play(station: RadioStationEntity) async throws
    func pause() async
    func stop() async
    func startLiveActivity(station: RadioStationEntity, isPlaying: Bool) async throws
    func updateLiveActivity(station: RadioStationEntity, isPlaying: Bool) async
    func endLiveActivity() async
}

final class PlayerUseCase: PlayerUseCaseProtocol {
    private let repository: PlayerRepositoryProtocol
    private var activity: Activity<RadioLiveActivityAttributes>?
    
    init(repository: PlayerRepositoryProtocol) {
        self.repository = repository
    }
    
    func play(station: RadioStationEntity) async throws {
        try await repository.play(station: station)
    }
    
    func pause() async {
        await repository.pause()
    }
    
    func stop() async {
        await repository.stop()
    }
    
    @MainActor
    func startLiveActivity(station: RadioStationEntity, isPlaying: Bool) async throws {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            return
        }
        let attributes = RadioLiveActivityAttributes(stationName: station.name)
        let contentState = RadioLiveActivityAttributes.ContentState(isPlaying: isPlaying)
        activity = try Activity.request(
            attributes: attributes,
            contentState: contentState,
            pushType: nil
        )
    }
    
    @MainActor
    func updateLiveActivity(station: RadioStationEntity, isPlaying: Bool) async {
        guard let activity = activity else { return }
        let contentState = RadioLiveActivityAttributes.ContentState(isPlaying: isPlaying)
        await activity.update(using: contentState)
    }
    
    @MainActor
    func endLiveActivity() async {
        guard let activity = activity else { return }
        await activity.end(using: nil, dismissalPolicy: .immediate)
        self.activity = nil
    }
}
