//
//  HomeView.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import SwiftUI
import ComposableArchitecture

/// Main view displaying list of radio stations with a mini-player at the bottom.
struct HomeView: View {
    @Bindable private var store: StoreOf<HomeReducer>

    init(store: StoreOf<HomeReducer>) {
        self.store = store
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    StationListView(store: store)
                        .contentMargins(.vertical, 16)
                }
                .scrollTargetBehavior(.paging)

                if let playerState = store.playerState {
                    MiniPlayerView(
                        store: store.scope(state: \.nonOptionalPlayerState, action: \.player),
                        station: playerState.station
                    )
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .background(.thinMaterial)
                    .containerShape(RoundedRectangle(cornerRadius: 8))
                    .contentMargins(.bottom, 16)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Mini player for \(playerState.station.name)")
                }
            }
            .navigationTitle("Radio Stations")
            .onAppear {
                store.send(.onAppear)
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
        .containerRelativeFrame(.vertical)
        .dynamicTypeSize(.large...DynamicTypeSize.xxxLarge)
        .animation(.easeInOut, value: store.playerState)
    }
}
