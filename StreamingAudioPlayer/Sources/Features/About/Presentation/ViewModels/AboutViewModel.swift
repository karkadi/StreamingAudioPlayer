//
//  AboutViewModel.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 08/04/2025.
//

import ComposableArchitecture

@Reducer
struct AboutViewModel {
    // MARK: - Dependencies
    @Dependency(\.aboutUseCase) private var aboutUseCase

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var aboutInfo = AboutInfoEntity(appName: "", creator: "", creationDate: "")
    }

    // MARK: - Actions
    enum Action {
        case onAppear
    }

    // MARK: - Reducer
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                // Fetch the about info when the view appears
                state.aboutInfo = aboutUseCase.fetchAboutInfo()
                return .none
            }
        }
    }
}
