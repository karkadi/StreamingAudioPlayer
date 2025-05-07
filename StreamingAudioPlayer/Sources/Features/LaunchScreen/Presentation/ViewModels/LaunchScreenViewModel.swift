//
//  LaunchScreenViewModel.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 06/04/2025.
//

import ComposableArchitecture

@Reducer
struct LaunchScreenViewModel {
    // MARK: - Dependencies
    @Dependency(\.useCaseLaunchScreen) private var useCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var entity: LaunchScreenEntity = .splashScreen
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
                state.entity = useCase.goToScreen(to: .landingScreen)
                return .none

            case .startButtonTapped:
                state.entity = useCase.goToScreen(to: .appScreen)
                return .none
            }
        }
    }
}
