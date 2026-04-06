//
//  HomeReducer.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import ComposableArchitecture
import Foundation
import OSLog

@Reducer
struct HomeReducer {
    private let logger = Logger(subsystem: "karkadi.com.StreamingAudioPlayer", category: "HomeReducer")
    
    @Reducer
    enum Path {
        case playerView(PlayerReducer)
        case aboutView
    }
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var stations: [RadioStationEntity] = []
        var favoriteStationIds: [Int] = []
        var isLoading: Bool = false
        var error: String?
        var playerState: PlayerReducer.State?
        var selectedFilter: StationFilter = .all
        // swiftlint:disable nesting
        enum StationFilter: String, CaseIterable {
            case all = "All"
            case favorites = "Favorites"
        }
        // swiftlint:enable nesting
        var displayedStations: [RadioStationEntity] {
            switch selectedFilter {
            case .all:
                return stations
            case .favorites:
                return stations.filter { favoriteStationIds.contains($0.id) }
            }
        }
        
        /// Computed property to provide non-optional player state for scoping.
        var nonOptionalPlayerState: PlayerReducer.State {
            get { playerState ?? PlayerReducer.State(station: RadioStationEntity(id: 1,
                                                                                 name: "Радио 1.FM",
                                                                                 imagrUrl: URL(string: "https://radiopotok.ru/f/station/512/38.png")!,
                                                                                 streamURL: URL(string: "https://strm112.1.fm/top40_mobile_mp3")!)) }
            set { playerState = newValue }
        }
    }
    
    enum Action: ViewAction, BindableAction {
        case binding(BindingAction<State>)
        
        case stationsLoaded([RadioStationEntity])
        case failedToLoad(Error)
        case player(PlayerReducer.Action)
        case pauseTapped
        case favoriteIdsLoaded([Int])

        case view(View)
        // swiftlint:disable nesting
        enum View {
            case onAppear
            case navigateToPlayer(RadioStationEntity)
            case navigateToAbout
            case playTapped(RadioStationEntity)
            case toggleFavorite(Int)
        }
        // swiftlint:enable nesting
    }
    
    // MARK: - Dependencies
    @Dependency(\.homeClient) var homeClient
    @Dependency(\.playerClient) var playerClient
    @Dependency(\.databaseClient) var databaseClient
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                    
                case .onAppear:
                    state.isLoading = true
                    return .run { send in
                        let stations = try await homeClient.fetchStations()
                        await send(.stationsLoaded(stations))
                        do {
                            let favoriteIds = try await databaseClient.getFavoriteStationIds()
                            await send(.favoriteIdsLoaded(favoriteIds))
                        } catch {
                            logger.error("Failed to load favorites: \(error)")
                            await send(.failedToLoad(error))
                        }
                    }
                    
                case .playTapped(let station):
                    state.playerState = PlayerReducer.State(station: station, isPlaying: true)
                    return .run { [station] send in
                        do {
                            try await playerClient.play(station)
                        } catch {
                            await send(.player(.playbackFailed(error.localizedDescription)))
                        }
                    }
                    
                case .toggleFavorite(let stationId):
                    let hasFavorite = state.favoriteStationIds.contains(stationId)
                    if hasFavorite {
                        state.favoriteStationIds.removeAll { $0 == stationId }
                    } else {
                        state.favoriteStationIds.append(stationId)
                    }
                    return .run { [hasFavorite, stationId] _ in
                        if hasFavorite {
                            do {
                                try await databaseClient.removeFavorite(stationId)
                            } catch {
                                logger.error("Failed to remove favorite: \(error)")
                            }
                        } else {
                            do {
                                try await databaseClient.addFavorite(stationId)
                            } catch {
                                logger.error("Failed to add favorite: \(error)")
                            }
                        }
                    }
                    
                case .navigateToPlayer, .navigateToAbout:
                    return .none
                }
                
            case .favoriteIdsLoaded(let ids):
                state.favoriteStationIds = ids
                return .none
                
            case .stationsLoaded(let stations):
                state.isLoading = false
                state.stations = stations
                return .none
                
            case .failedToLoad(let error):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case .pauseTapped:
                if state.playerState != nil {
                    state.playerState?.isPlaying = false
                    return .run { _ in
                        await playerClient.pause()
                    }
                }
                return .none
                
            case .player(.playbackFailed(let message)):
                state.playerState?.isPlaying = false
                state.playerState?.error = message
                return .none
                
            case .player:
                return .none
                
            case .binding:
                return .none
            }
        }
        .ifLet(\.playerState, action: \.player) {
            PlayerReducer()
        }
      //  ._printChanges()
    }
}
