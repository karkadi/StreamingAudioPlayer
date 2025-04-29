//
//  HomeReducer.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Features/Home/Presentation/HomeReducer.swift
import ComposableArchitecture
import Foundation

@Reducer
struct HomeReducer {
    @ObservableState
    struct State: Equatable {
        var stations: [RadioStationEntity] = []
        var isLoading: Bool = false
        var error: String?
        var playerState: PlayerReducer.State?

        /// Computed property to provide non-optional player state for scoping.
        var nonOptionalPlayerState: PlayerReducer.State {
            get { playerState ?? PlayerReducer.State(station: RadioStationEntity(id: UUID(), name: "", streamURL: URL(string: "https://example.com")!)) }
            set { playerState = newValue }
        }
    }

    enum Action {
        case onAppear
        case stationsLoaded([RadioStationEntity])
        case failedToLoad(Error)
        case player(PlayerReducer.Action)
        case playTapped(RadioStationEntity)
        case pauseTapped
    }

    @Dependency(\.homeUseCase) var homeUseCase
    @Dependency(\.playerUseCase) var playerUseCase

    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.isLoading = true
                return .run { send in
                    do {
                        let stations = try await homeUseCase.fetchStations()
                        await send(.stationsLoaded(stations))
                    } catch {
                        await send(.failedToLoad(error))
                    }
                }

            case .stationsLoaded(let stations):
                state.isLoading = false
                state.stations = stations
                return .none

            case .failedToLoad(let error):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .playTapped(let station):
                state.playerState = PlayerReducer.State(station: station, isPlaying: true)
                return .run { [station] send in
                    do {
                        try await playerUseCase.play(station: station)
                    } catch {
                        await send(.player(.playbackFailed(error)))
                    }
                }

            case .pauseTapped:
                if state.playerState != nil {
                    state.playerState?.isPlaying = false
                    return .run { _ in
                        await playerUseCase.pause()
                    }
                }
                return .none

            case .player(.playbackFailed(let error)):
                state.playerState?.isPlaying = false
                state.playerState?.error = error.localizedDescription
                return .none

            case .player:
                return .none
            }
        }
        .ifLet(\.playerState, action: \.player) {
            PlayerReducer()
        }
    }
}
