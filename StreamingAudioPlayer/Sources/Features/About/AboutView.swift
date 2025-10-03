//
//  AboutView.swift
//  InstagramLikeApp
//
//  Created by Arkadiy KAZAZYAN on 08/04/2025.
//

import ComposableArchitecture
import SwiftUI

struct AboutView: View {
    let store: StoreOf<AboutReducer>

    var body: some View {
        ZStack {
            MetalView(fragmentFunction: "fragment_main_matrix")

            VStack(spacing: 16) {
                Spacer()

                if let aboutInfo = store.aboutInfo {
                    VStack(spacing: 28) {
                        Text(aboutInfo.appName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text(aboutInfo.creator)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(aboutInfo.creationDate)
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
        }
        .background(Color.background)
        .transition(.opacity)
        .ignoresSafeArea(.all)
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    AboutView(store: Store( initialState: AboutReducer.State()) { AboutReducer() })
}
