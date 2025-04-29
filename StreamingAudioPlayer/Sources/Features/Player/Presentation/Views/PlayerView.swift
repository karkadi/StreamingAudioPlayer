//
//  PlayerView.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Features/Player/Presentation/Views/PlayerView.swift
import SwiftUI
import ComposableArchitecture

/// View for controlling audio playback.
struct PlayerView: View {
    @Bindable private var store: StoreOf<PlayerReducer>

    init(store: StoreOf<PlayerReducer>) {
        self.store = store
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(store.station.name)
                .font(.title)
                .accessibilityLabel("Playing \(store.station.name)")

            if let error = store.error {
                Text("Error: \(error)")
                    .foregroundStyle(.red)
                    .accessibilityLabel("Playback error: \(error)")
            }

            HStack(spacing: 20) {
                Button(action: {
                    store.send(.playTapped)
                    triggerHaptic()
                }) {
                    Image(systemName: "play.fill")
                        .font(.title2)
                }
                .buttonStyle(PlayButtonStyle())
                .disabled(store.isPlaying)
                .accessibilityLabel("Play")
                .accessibilityHint("Starts playing \(store.station.name)")

                Button(action: {
                    store.send(.pauseTapped)
                    triggerHaptic()
                }) {
                    Image(systemName: "pause.fill")
                        .font(.title2)
                }
                .buttonStyle(PlayButtonStyle())
                .disabled(!store.isPlaying)
                .accessibilityLabel("Pause")
                .accessibilityHint("Pauses playback")

                Button(action: {
                    store.send(.stopTapped)
                    triggerHaptic()
                }) {
                    Image(systemName: "stop.fill")
                        .font(.title2)
                }
                .buttonStyle(PlayButtonStyle())
                .accessibilityLabel("Stop")
                .accessibilityHint("Stops playback")
            }
        }
        .containerRelativeFrame(.vertical)
        .navigationTitle("Player")
        .dynamicTypeSize(.large...DynamicTypeSize.xxxLarge)
        .sensoryFeedback(.impact, trigger: store.isPlaying)
    }

    private func triggerHaptic() {
#if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
#endif
    }
}

#Preview {
    let station = RadioStationEntity(id: UUID(), name: "France Inter", streamURL: URL(string: "https://icecast.radiofrance.fr/franceinter-hifi.aac")!)
    PlayerView(
        store: Store(
            initialState: PlayerReducer.State(station: station),
            reducer: { PlayerReducer() }
        )
    )
}
