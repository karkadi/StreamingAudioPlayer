//
//  StationFormReducer.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 19/07/2026.
//

import ComposableArchitecture
import Foundation

/// Drives the add/edit form for a single radio station.
/// Reports the outcome back to its parent via `Delegate` rather than talking
/// to the database directly, so `HomeReducer` stays the single place that
/// owns station persistence.
@Reducer
struct StationFormReducer: Sendable {
    enum Mode: Equatable, Sendable {
        case add
        case edit(id: Int)
    }

    @ObservableState
    struct State: Equatable, Sendable {
        var mode: Mode
        var name: String
        var imageUrlString: String
        var streamUrlString: String
        var errorMessage: String?
        init(mode: Mode, name: String = "", imageUrlString: String = "", streamUrlString: String = "") {
            self.mode = mode
            self.name = name
            self.imageUrlString = imageUrlString
            self.streamUrlString = streamUrlString
        }
        
        /// Convenience initializer that pre-fills the form from an existing station.
        init(editing station: RadioStationEntity) {
            self.init(
                mode: .edit(id: station.id),
                name: station.name,
                imageUrlString: station.imagrUrl.absoluteString,
                streamUrlString: station.streamURL.absoluteString
            )
        }
        
        var navigationTitle: String {
            switch mode {
            case .add: return "Add Station"
            case .edit: return "Edit Station"
            }
        }
    }
    
    enum Action: ViewAction, BindableAction, Sendable {
        case binding(BindingAction<State>)
        case delegate(Delegate)
        case view(View)
        // swiftlint:disable nesting
        enum View: Sendable {
            case saveTapped
            case cancelTapped
        }
        
        enum Delegate: Sendable, Equatable {
            /// `id == nil` means "add"; a non-nil id means "edit that station".
            case save(id: Int?, name: String, imagrUrl: URL, streamURL: URL)
            case cancel
        }
        // swiftlint:enable nesting
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .saveTapped:
                    let trimmedName = state.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedName.isEmpty else {
                        state.errorMessage = "Please enter a station name."
                        return .none
                    }
                    guard let imageUrl = URL(string: state.imageUrlString),
                          imageUrl.scheme != nil else {
                        state.errorMessage = "Please enter a valid image URL."
                        return .none
                    }
                    guard let streamUrl = URL(string: state.streamUrlString),
                          streamUrl.isValidStreamingURL else {
                        state.errorMessage = "Please enter a valid http(s) stream URL."
                        return .none
                    }
                    state.errorMessage = nil
                    
                    let id: Int?
                    switch state.mode {
                    case .add: id = nil
                    case .edit(let existingId): id = existingId
                    }
                    return .send(.delegate(.save(id: id, name: trimmedName, imagrUrl: imageUrl, streamURL: streamUrl)))
                    
                case .cancelTapped:
                    return .send(.delegate(.cancel))
                }
                
            case .binding, .delegate:
                return .none
            }
        }
    }
}
