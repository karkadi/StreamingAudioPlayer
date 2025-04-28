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
                ForEach(store.stations) { station in
                    NavigationLink(
                        value: station
                    ) {
                        StationRow(station: station)
                    }
                    .accessibilityLabel("Select \(station.name)")
                    .accessibilityHint("Navigates to player for \(station.name)")
                }
            }
        }
        .navigationDestination(for: RadioStationEntity.self) { station in
            PlayerView(
                store: Store(
                    initialState: PlayerReducer.State(station: station),
                    reducer: { PlayerReducer() }
                )
            )
        }
    }
}
