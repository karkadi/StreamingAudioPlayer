//
//  PlayerReducer.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct PlayerReducer: Sendable {
    @ObservableState
    struct State: Equatable, Sendable {
        let station: RadioStationEntity
        var isPlaying: Bool = false
        var error: String?
    }
    
    enum Action: ViewAction, Sendable {
        case playbackFailed(String)

        case view(View)
        // swiftlint:disable nesting
        enum View: Sendable {
            case playTapped
            case pauseTapped
            case stopTapped
            case externalPlaybackStateChanged(Bool)
        }
        // swiftlint:enable nesting
    }
    
    @Dependency(\.playerClient) var playerClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .playTapped:
                    state.isPlaying = true
                    return .run { [station = state.station] send in
                        do {
                            try await playerClient.play(station)
                        } catch {
                            await send(.playbackFailed(error.localizedDescription))
                        }
                    }
                    
                case .pauseTapped:
                    state.isPlaying = false
                    return .run { _ in
                        await playerClient.pause()
                    }
                    
                case .stopTapped:
                    state.isPlaying = false
                    return .run { _ in
                        await playerClient.stop()
                    }
                    
                case .externalPlaybackStateChanged(let isPlaying):
                    state.isPlaying = isPlaying
                    return .none
                    
                }
            
            case .playbackFailed(let message):
                state.isPlaying = false
                state.error = message
                return .run { _ in
                    await playerClient.stop()
                }
            }
        }
    }
}
