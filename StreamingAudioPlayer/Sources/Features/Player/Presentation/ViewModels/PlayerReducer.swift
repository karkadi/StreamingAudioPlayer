//
//  PlayerReducer.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct PlayerReducer {
    @ObservableState
    struct State: Equatable {
        let station: RadioStationEntity
        var isPlaying: Bool = false
        var error: String?
    }

    enum Action {
        case playTapped
        case pauseTapped
        case stopTapped
        case playbackFailed(Error)
        case externalPlaybackStateChanged(Bool)
    }

    @Dependency(\.playerUseCase) var playerUseCase

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .playTapped:
                state.isPlaying = true
                return .run { [station = state.station] send in
                    do {
                        try await playerUseCase.play(station: station)
                    } catch {
                        await send(.playbackFailed(error))
                    }
                }

            case .pauseTapped:
                state.isPlaying = false
                return .run { send in
                    await playerUseCase.pause()
                }

            case .stopTapped:
                state.isPlaying = false
                return .run { _ in
                    await playerUseCase.stop()
                }

            case .playbackFailed(let error):
                state.isPlaying = false
                state.error = error.localizedDescription
                return .run { send in
                    await playerUseCase.stop()
                }

            case .externalPlaybackStateChanged(let isPlaying):
                state.isPlaying = isPlaying
                return .none

            }
        }
    }
}
