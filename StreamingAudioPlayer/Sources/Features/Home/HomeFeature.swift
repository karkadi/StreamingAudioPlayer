//
//  HomeFeature.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import ComposableArchitecture
import Foundation
import OSLog

@Reducer
struct HomeFeature {
    private let logger = Logger(subsystem: "karkadi.com.StreamingAudioPlayer", category: "HomeFeature")

    @Reducer(state: .equatable)
    enum Path {
        case playerView(PlayerFeature)
        case aboutView
    }

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var stations: [RadioStationEntity] = []
        var favoriteStationIds: [Int] = []
        var isLoading: Bool = false
        var error: String?
        var playerState: PlayerFeature.State?
        var selectedFilter: StationFilter = .all
        var path = StackState<Path.State>()

        enum StationFilter: String, CaseIterable {
            case all = "All"
            case favorites = "Favorites"
        }

        var displayedStations: [RadioStationEntity] {
            switch selectedFilter {
            case .all:
                return stations
            case .favorites:
                return stations.filter { favoriteStationIds.contains($0.id) }
            }
        }

        /// Computed property to provide non-optional player state for scoping.
        var nonOptionalPlayerState: PlayerFeature.State {
            get { playerState ?? PlayerFeature.State(station: RadioStationEntity(id: 1,
                                                                                 name: "Радио 1.FM",
                                                                                 imagrUrl: URL(string:"https://radiopotok.ru/f/station/512/38.png")!,
                                                                                 streamURL: URL(string: "https://strm112.1.fm/top40_mobile_mp3")!)) }
            set { playerState = newValue }
        }
    }

    enum Action: ViewAction {
        case view(View)
        case path(StackActionOf<Path>)

        case stationsLoaded([RadioStationEntity])
        case failedToLoad(Error)
        case player(PlayerFeature.Action)
        case playTapped(RadioStationEntity)
        case pauseTapped
        case favoriteIdsLoaded([Int])
        case toggleFavorite(Int)
        case filterChanged(State.StationFilter)

        enum View {
            case onAppear
            case showAbout
        }
    }

    // MARK: - Dependencies
    @Dependency(\.homeClient) var homeClient
    @Dependency(\.playerClient) var playerClient
    @Dependency(\.databaseClient) var databaseClient

    var body: some Reducer<State, Action> {

        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                state.isLoading = true
                return .run { send in
                    let stations = await homeClient.fetchStations()
                    await send(.stationsLoaded(stations))
                    do {
                        let favoriteIds = try await databaseClient.getFavoriteStationIds()
                        await send(.favoriteIdsLoaded(favoriteIds))
                    } catch {
                        logger.error("Failed to load favorites: \(error)")
                        await send(.failedToLoad(error))
                    }
                }

            case .favoriteIdsLoaded(let ids):
                state.favoriteStationIds = ids
                return .none

            case .toggleFavorite(let stationId):
                let hasFavorite = state.favoriteStationIds.contains(stationId)
                if hasFavorite {
                    state.favoriteStationIds.removeAll { $0 == stationId }
                } else {
                    state.favoriteStationIds.append(stationId)
                }
                return .run { [hasFavorite, stationId] send in
                    if hasFavorite {
                        do {
                            try await databaseClient.removeFavorite(stationId: stationId)
                        } catch {
                            logger.error("Failed to remove favorite: \(error)")
                        }
                    } else {
                        do {
                            try await databaseClient.addFavorite(stationId: stationId)
                        } catch {
                            logger.error("Failed to add favorite: \(error)")
                        }
                    }
                }

            case .filterChanged(let filter):
                state.selectedFilter = filter
                return .none

            case .stationsLoaded(let stations):
                state.isLoading = false
                state.stations = stations
                return .none

            case .failedToLoad(let error):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none

            case .playTapped(let station):
                state.playerState = PlayerFeature.State(station: station, isPlaying: true)
                return .run { [station] send in
                    do {
                        try await playerClient.play(station: station)
                    } catch {
                        await send(.player(.playbackFailed(error)))
                    }
                }

            case .pauseTapped:
                if state.playerState != nil {
                    state.playerState?.isPlaying = false
                    return .run { _ in
                        await playerClient.pause()
                    }
                }
                return .none

            case .player(.playbackFailed(let error)):
                state.playerState?.isPlaying = false
                state.playerState?.error = error.localizedDescription
                return .none

            case .player:
                return .none

            case .path:
                return .none
                
            case .view(.showAbout):
                state.path.append(.aboutView)
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.playerState, action: \.player) {
            PlayerFeature()
        }
        ._printChanges()
    }
}
