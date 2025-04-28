//
//  HomeView.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Features/Home/Presentation/Views/HomeView.swift
import SwiftUI
import ComposableArchitecture

/// Main view displaying list of radio stations.
struct HomeView: View {
    @Bindable private var store: StoreOf<HomeReducer>

    init(store: StoreOf<HomeReducer>) {
        self.store = store
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                StationListView(store: store)
                    .contentMargins(.vertical, 16)
            }
            .navigationTitle("Radio Stations")
            .scrollTargetBehavior(.paging)
            .onAppear {
                store.send(.onAppear)
            }
        }
        .containerRelativeFrame(.vertical)
        .dynamicTypeSize(.large...DynamicTypeSize.xxxLarge)
    }
}

#Preview {
    HomeView(
        store: Store(
            initialState: HomeReducer.State(),
            reducer: { HomeReducer() }
        )
    )
}

