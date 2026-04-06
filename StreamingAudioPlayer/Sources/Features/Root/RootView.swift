//
//  RootView.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 19/07/2025.
//
import ComposableArchitecture
import SwiftUI

// MARK: - Views
struct RootView: View {
    @Bindable var store: StoreOf<RootReducer>
    
    var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            HomeView(store: store.scope(state: \.main, action: \.main))
        } destination: { store in
            switch store.state {
            case .about:
                if let store = store.scope(state: \.about, action: \.about) {
                    AboutView(store: store)
                }
            case .player:
                if let store = store.scope(state: \.player, action: \.player) {
                    PlayerView(store: store)
                }
            }
        }
    }
}

#Preview {
    RootView(store: Store(initialState: RootReducer.State()) { RootReducer() })
}
