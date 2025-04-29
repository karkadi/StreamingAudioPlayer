//
//  MiniPlayerView.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 29/04/2025.
//

// Sources/Shared/Components/MiniPlayerView.swift
import SwiftUI
import ComposableArchitecture

/// Mini-player view displayed at the bottom of the main screen with a volume level bar.
struct MiniPlayerView: View {
    @Bindable private var store: StoreOf<PlayerReducer>
    private let station: RadioStationEntity

    init(store: StoreOf<PlayerReducer>, station: RadioStationEntity) {
        self.store = store
        self.station = station
    }

    var body: some View {
        NavigationLink(value: station) {
            HStack {
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
        .buttonStyle(.plain)
        .accessibilityHint("Tap to view full player")
    }

    private func triggerHaptic() {
        #if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        #endif
    }
}
