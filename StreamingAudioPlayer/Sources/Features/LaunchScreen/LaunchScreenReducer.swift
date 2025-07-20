//
//  LaunchScreenReducer.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 06/04/2025.
//

import ComposableArchitecture

@Reducer
struct LaunchScreenReducer {
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var entity: Screen = .splashScreen

        enum Screen {
            case splashScreen
            case landingScreen
            case appScreen
        }
    }

    // MARK: - Action
    enum Action {
        case onAppear          // Triggered when the view appears
        case startButtonTapped // User taps "Start" on landing screen
    }

    // MARK: - Reducer
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.entity = .landingScreen
                return .none

            case .startButtonTapped:
                state.entity = .appScreen
                return .none
            }
        }
    }
}
