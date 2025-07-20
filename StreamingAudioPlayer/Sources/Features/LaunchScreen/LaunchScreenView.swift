//
//  LaunchScreenView.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 06/04/2025.
//

import ComposableArchitecture
import SwiftUI

struct LaunchScreenView: View {
    let store: StoreOf<LaunchScreenReducer>

    init() {
        self.store = Store(initialState: LaunchScreenReducer.State()) { LaunchScreenReducer() }
    }

    var body: some View {
        switch store.state.entity {
        case .splashScreen:
            Color.background
                .ignoresSafeArea(edges: .all)
                .onAppear {
                    store.send(.onAppear, animation: .easeInOut(duration: 2.0))
                }

        case .landingScreen:
            landingScreen

        case .appScreen:
            RootView( store: Store( initialState: RootReducer.State(),
                                    reducer: { RootReducer() }
                                  )
            )
        }
    }

    // Landing Screen
    private var landingScreen: some View {
        ZStack {
            MetalView(fragmentFunction: "fragment_main_fire")

            VStack {
                Spacer()
                Button(action: {
                    store.send(.startButtonTapped, animation: .easeInOut(duration: 1.0))
                }, label: {
                    Text("Start")
                        .font(.title)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(lineWidth: 2))
                        .foregroundColor(.yellow)
                        .shadow(color: .yellow, radius: 5)
                        .shadow(color: .yellow, radius: 20)
                        .shadow(color: .yellow, radius: 50)
                })
                Spacer()
            }
            .padding([.leading, .trailing], 50)
        }
        .background(Color.background)
        .transition(.opacity)
        .ignoresSafeArea(.all)
    }
}

#Preview {
    LaunchScreenView()
}
