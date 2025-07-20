//
//  HomeView.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import SwiftUI
import ComposableArchitecture

/// Main view displaying list of radio stations with a mini-player at the bottom.
@ViewAction(for: HomeReducer.self)
struct HomeView: View {
    @Bindable var store: StoreOf<HomeReducer>

    var body: some View {

        VStack {
            Picker("Filter",
                   selection: $store.selectedFilter.sending(\.filterChanged)) {
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
                    send(.navigateToAbout)
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            send(.onAppear)
        }
        .containerRelativeFrame(.vertical)
        .dynamicTypeSize(.large...DynamicTypeSize.xxxLarge)
        .animation(.easeInOut, value: store.playerState)
    }

}
