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
    @State private var showAboutView = false
    @State private var selectedFilter: HomeReducer.State.StationFilter = .all

    init(store: StoreOf<HomeReducer>) {
        self.store = store
    }

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(HomeReducer.State.StationFilter.allCases, id: \.self) { filter in
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
                        showAboutView = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .sheet(isPresented: $showAboutView) {
                AboutView()
            }
            .onAppear {
                store.send(.onAppear)
            }
            .onChange(of: selectedFilter) { _, newValue in
                store.send(.filterChanged(newValue))
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
