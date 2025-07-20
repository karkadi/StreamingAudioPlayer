//
//  AboutReducer.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 08/04/2025.
//

import ComposableArchitecture

@Reducer
struct AboutReducer {
    // MARK: - Dependencies
    @Dependency(\.aboutClient) private var aboutClient

    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var aboutInfo = AboutInfoModel(appName: "", creator: "", creationDate: "")
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
                state.aboutInfo = aboutClient
                return .none
            }
        }
    }
}
