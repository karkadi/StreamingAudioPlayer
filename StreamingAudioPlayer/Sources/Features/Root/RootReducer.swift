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
    struct State: Equatable {
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
        .forEach(\.path, action: \.path) {
            Path()
        }
    }

    // MARK: - Path Reducer
    @Reducer
    struct Path {
        // swiftlint:disable nesting
        @ObservableState
        enum State: Equatable {
            case player(PlayerReducer.State)
            case about(AboutReducer.State)
        }

        enum Action {
            case player(PlayerReducer.Action)
            case about(AboutReducer.Action)
        }
        // swiftlint:enable nesting
        var body: some Reducer<State, Action> {
            Scope(state: \.player, action: \.player) {
                PlayerReducer()
            }
            Scope(state: \.about, action: \.about) {
                AboutReducer()
            }
        }
    }
}
