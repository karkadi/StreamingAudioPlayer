//
//  StationListView.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import SwiftUI
import ComposableArchitecture

/// Subview for displaying the list of radio stations.
struct StationListView: View {
    @Bindable private var store: StoreOf<HomeReducer>

    init(store: StoreOf<HomeReducer>) {
        self.store = store
    }

    var body: some View {
        LazyVStack(spacing: 16) {
            if store.isLoading {
                ProgressView()
                    .accessibilityLabel("Loading stations")
            } else if let error = store.error {
                Text("Error: \(error)")
                    .foregroundStyle(.red)
                    .accessibilityLabel("Error: \(error)")
            } else {
                ForEach(store.displayedStations) { station in
                    Button {
                        store.send(.playTapped(station))
                    } label: {
                        StationRow(station: station,
                                   isFavorite: store.favoriteStationIds.contains(station.id),
                                   onFavoriteToggle : {
                            store.send(.toggleFavorite(station.id))
                        })
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Play \(station.name)")
                    .accessibilityHint("Starts playing \(station.name)")
                }
            }
        }
    }
}
