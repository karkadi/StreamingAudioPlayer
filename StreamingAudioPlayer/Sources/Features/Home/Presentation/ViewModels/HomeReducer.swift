//
//  HomeReducer.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import ComposableArchitecture
import Foundation

@Reducer
struct HomeReducer {
    @ObservableState
    struct State: Equatable {
        var stations: [RadioStationEntity] = []
        var favoriteStationIds: [Int] = []
        var isLoading: Bool = false
        var error: String?
        var playerState: PlayerReducer.State?
        var selectedFilter: StationFilter = .all
        
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
        var nonOptionalPlayerState: PlayerReducer.State {
            get { playerState ?? PlayerReducer.State(station: RadioStationEntity(id: 1,
                                                                                 name: "Радио 1.FM",
                                                                                 imagrUrl: URL(string:"https://radiopotok.ru/f/station/512/38.png")!,
                                                                                 streamURL: URL(string: "https://strm112.1.fm/top40_mobile_mp3")!)) }
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
        case favoriteIdsLoaded([Int])
        case toggleFavorite(Int)
        case filterChanged(State.StationFilter)
    }
    
    @Dependency(\.homeUseCase) var homeUseCase
    @Dependency(\.playerUseCase) var playerUseCase
    @Dependency(\.favoriteUseCase) var favoriteUseCase
    
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
                    do {
                        let favoriteIds = try await favoriteUseCase.getFavoriteStationIds()
                        await send(.favoriteIdsLoaded(favoriteIds))
                    } catch {
                        print("Failed to load favorites: \(error)")
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
                            try await favoriteUseCase.removeFavorite(stationId: stationId)
                        } catch {
                            print("Failed to remove favorite: \(error)")
                        }
                    } else {
                        do {
                            try await favoriteUseCase.addFavorite(stationId: stationId)
                        } catch {
                            print("Failed to add favorite: \(error)")
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
