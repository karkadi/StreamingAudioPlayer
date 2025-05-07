//
//  MiniPlayerView.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 29/04/2025.
//

import SwiftUI
import ComposableArchitecture
import CachedAsyncImage

/// Mini-player view displayed at the bottom of the main screen with a volume level bar.
struct MiniPlayerView: View {
    @Bindable private var store: StoreOf<PlayerReducer>
    @State private var audioStateObserver = AudioStateObserver()
    private let station: RadioStationEntity

    init(store: StoreOf<PlayerReducer>, station: RadioStationEntity) {
        self.store = store
        self.station = station
    }

    var body: some View {
        NavigationLink(value: station) {
            HStack {
                CachedAsyncImage(url: station.imagrUrl.absoluteString,
                                 placeholder: { progress in
                    ZStack {
                        Color.background
                        ProgressView {
                            Text("\(progress) %")
                        }
                    }
                },
                                 image: {
                    // Customize image.
                    Image(uiImage: $0)
                        .resizable()
                        .scaledToFill()
                })
                 .frame(width: 30, height: 30)

                Text(station.name)
                    .font(.subheadline)
                    .lineLimit(1)
                    .accessibilityLabel("Currently playing \(station.name)")

                Spacer()

                VolumeLevelBar(isPlaying: store.isPlaying)
                    .accessibilityLabel("Playback volume indicator")
                    .accessibilityValue(store.isPlaying ? "Playing" : "Paused")
                    .accessibilityHidden(!store.isPlaying)

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
            .padding()
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
            .contentMargins(.horizontal, 16)
        }
        .onAppear {
            store.send(.externalPlaybackStateChanged(audioStateObserver.isPlaying))
        }
        .onChange(of: audioStateObserver.isPlaying) { _, newValue in
            store.send(.externalPlaybackStateChanged(newValue))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Tap to view full player")
    }

    private func triggerHaptic() {
#if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
#endif
    }
}
