//
//  RootReducer.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 19/07/2025.
//

import ComposableArchitecture

// MARK: - App Root Reducer
@Reducer
struct RootReducer {
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        var main = HomeReducer.State()
    }

    enum Action {
        case main(HomeReducer.Action)
        case path(StackAction<Path.State, Path.Action>)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.main, action: \.main) {
            HomeReducer()
        }
        Reduce { state, action in
            switch action {
            case .main(.view(.navigateToPlayer(let station))):
                state.path.append(.player(PlayerReducer.State(station: station)))
                return .none

            case .main(.view(.navigateToAbout)):
                state.path.append(.about(AboutReducer.State()))
                return .none

            default:
                return .none
            }
        }
        .forEach(\.path, action: \.path) 
    }

    // MARK: - Path Reducer
    @Reducer
    enum Path {
        case player(PlayerReducer)
        case about(AboutReducer)
    }
    
}
