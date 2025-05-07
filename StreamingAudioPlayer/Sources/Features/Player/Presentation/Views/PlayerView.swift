//
//  PlayerView.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import SwiftUI
import ComposableArchitecture
import CachedAsyncImage

/// Full-screen player view for controlling playback.
struct PlayerView: View {
    @Bindable private var store: StoreOf<PlayerReducer>
    @State private var audioStateObserver = AudioStateObserver()

    init(store: StoreOf<PlayerReducer>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 16) {

            CachedAsyncImage(url: store.station.imagrUrl.absoluteString,
                             placeholder: { progress in
                ZStack {
                    Color.background
                    ProgressView {
                        VStack {
                            Text("Loading...")
                            Text("\(progress) %")
                        }
                    }
                }
            },
                             image: {
                // Customize image.
                Image(uiImage: $0)
                    .resizable()
                    .scaledToFill()
            })
            .frame(width: 200, height: 200)

            Text(store.station.name)
                .font(.title)
                .lineLimit(1)
                .accessibilityLabel("Playing \(store.station.name)")

            if let error = store.error {
                Text("Error: \(error)")
                    .foregroundStyle(.red)
                    .accessibilityLabel("Playback error: \(error)")
            }

            Button(action: {
                if store.isPlaying {
                    store.send(.pauseTapped)
                } else {
                    store.send(.playTapped)
                }
                triggerHaptic()
            }) {
                Image(systemName: store.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .symbolEffect(.bounce, value: store.isPlaying)
            }
            .buttonStyle(PlayButtonStyle())
            .accessibilityLabel(store.isPlaying ? "Pause" : "Play")
            .accessibilityHint(store.isPlaying ? "Pauses playback" : "Resumes playback")

        }
        .containerRelativeFrame(.vertical)
        .navigationTitle("Player")
        .dynamicTypeSize(.large...DynamicTypeSize.xxxLarge)
        .sensoryFeedback(.impact, trigger: store.isPlaying)
        .onAppear {
            store.send(.externalPlaybackStateChanged(audioStateObserver.isPlaying))
        }
        .onChange(of: audioStateObserver.isPlaying) { _, newValue in
            store.send(.externalPlaybackStateChanged(newValue))
        }

    }

    private func triggerHaptic() {
#if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
#endif
    }
}

#Preview {
    let station = RadioStationEntity(id: UUID(),
                                     name: "Радио 1.FM",
                                     imagrUrl: URL(string:"https://radiopotok.ru/f/station/512/38.png")!,
                                     streamURL: URL(string: "https://strm112.1.fm/top40_mobile_mp3")!)
    PlayerView(
        store: Store(
            initialState: PlayerReducer.State(station: station),
            reducer: { PlayerReducer() }
        )
    )
}
