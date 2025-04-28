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
        var selectedStation: RadioStationEntity?
    }

    enum Action {
        case onAppear
        case stationsLoaded([RadioStationEntity])
        case failedToLoad(Error)
        case selectStation(RadioStationEntity?)
    }

    @Dependency(\.homeUseCase) var homeUseCase

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

            case .selectStation(let station):
                state.selectedStation = station
                return .none
            }
        }
    }
}
