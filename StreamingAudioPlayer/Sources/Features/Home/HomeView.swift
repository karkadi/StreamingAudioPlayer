//
//  HomeView.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import SwiftUI
import ComposableArchitecture

/// Main view displaying list of radio stations with a mini-player at the bottom.
@ViewAction(for: HomeFeature.self)
struct HomeView: View {
    @Bindable var store: StoreOf<HomeFeature>
    init(store: StoreOf<HomeFeature>) {
        self.store = store
    }

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            VStack {
                Picker("Filter",
                       selection: $store.selectedFilter.sending(\.filterChanged)) {
                    ForEach(HomeFeature.State.StationFilter.allCases, id: \.self) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                       .pickerStyle(.segmented)
                       .padding()
                       .accessibilityLabel("Station filter")
                       .accessibilityHint("Select to show all stations or only favorites")

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
            }
            .navigationTitle("Radio Stations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        send(.showAbout)
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                send(.onAppear)
            }
        } destination: { destination in
            switch destination.case {
            case .aboutView:
                AboutView()

            case let .playerView( playerStore):
                PlayerView(store: playerStore)
            }
        }
        .containerRelativeFrame(.vertical)
        .dynamicTypeSize(.large...DynamicTypeSize.xxxLarge)
        .animation(.easeInOut, value: store.playerState)
    }

}
