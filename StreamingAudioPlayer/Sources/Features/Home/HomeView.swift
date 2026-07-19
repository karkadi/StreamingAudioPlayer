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
                   selection: $store.selectedFilter) {
                ForEach(HomeReducer.State.StationFilter.allCases, id: \.self) { filter in
                    Text(filter.rawValue)
                        .tag(filter)
                }
            }
                   .pickerStyle(.segmented)
                   .padding()
                   .accessibilityLabel("Station filter")
                   .accessibilityHint("Select to show all stations or only favorites")
            
            ZStack(alignment: .bottom) {
                stationListView
                
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    send(.addStationTapped)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Add station")
                .accessibilityHint("Opens a form to add a new radio station")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    send(.navigateToAbout)
                } label: {
                    Image(systemName: "info.circle")
                }
            }
        }
        .onAppear {
            send(.onAppear)
        }
        .navigationTitle("Radio Stations")
#if (os(iOS))
        .navigationBarTitleDisplayMode(.inline)
#endif
        .containerRelativeFrame(.vertical)
        .dynamicTypeSize(.large...DynamicTypeSize.xxxLarge)
        .animation(.easeInOut, value: store.playerState)
        .sheet(item: $store.scope(state: \.stationForm, action: \.stationForm)) { formStore in
            StationFormView(store: formStore)
        }
    }
    
    private var stationListView: some View {
        List {
            if store.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .accessibilityLabel("Loading stations")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else if let error = store.error {
                Text("Error: \(error)")
                    .foregroundStyle(.red)
                    .accessibilityLabel("Error: \(error)")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(store.displayedStations) { station in
                    Button {
                        send(.playTapped(station))
                    } label: {
                        StationRow(station: station,
                                   isFavorite: store.favoriteStationIds.contains(station.id),
                                   onFavoriteToggle: {
                            send(.toggleFavorite(station.id))
                        },
                                   onEdit: {
                            send(.editStation(station))
                        },
                                   onDelete: {
                            send(.deleteStation(station.id))
                        })
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Play \(station.name)")
                    .accessibilityHint("Starts playing \(station.name)")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            send(.deleteStation(station.id))
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            send(.editStation(station))
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .contentMargins(.bottom, 90)
    }
    
}

#Preview {
    NavigationStack {
        HomeView(store: Store(initialState: HomeReducer.State()) { HomeReducer() })
    }
}
