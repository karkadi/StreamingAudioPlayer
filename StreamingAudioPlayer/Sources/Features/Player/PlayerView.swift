//
//  PlayerView.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import SwiftUI
import ComposableArchitecture
import CachedAsyncImage
import Metal

/// Full-screen player view for controlling playback.
@ViewAction(for: PlayerReducer.self)
struct PlayerView: View {
    @Bindable var store: StoreOf<PlayerReducer>
    @State private var audioStateObserver = AudioStateObserver()
    private let width: CGFloat = 200.0
    @State private var time: Float = 0
    
    init(store: StoreOf<PlayerReducer>) {
        self.store = store
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .colorEffect(ShaderLibrary.fractal(
                    .float4(0, 0, width, width),
                    .float(time)))
                .frame(width: width, height: width)
            
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
            .frame(width: width, height: width)
            
            Text(store.station.name)
                .font(.headline)
                .foregroundStyle(Color(.white))
                .lineLimit(1)
                .accessibilityLabel("Playing \(store.station.name)")
            
            if let error = store.error {
                Text("Error: \(error)")
                    .foregroundStyle(.red)
                    .accessibilityLabel("Playback error: \(error)")
            }
            
            Button(action: {
                if store.isPlaying {
                    send(.pauseTapped)
                } else {
                    send(.playTapped)
                }
                triggerHaptic()
            }, label: {
                Image(systemName: store.isPlaying ? "pause.fill" : "play.fill")
                    .font(.title3)
                    .symbolEffect(.bounce, value: store.isPlaying)
            })
            .buttonStyle(PlayButtonStyle())
            .accessibilityLabel(store.isPlaying ? "Pause" : "Play")
            .accessibilityHint(store.isPlaying ? "Pauses playback" : "Resumes playback")
            
        }
        .offset(y: -100)
        .containerRelativeFrame(.vertical)
        .navigationBarTitle("Player", displayMode: .inline)
        .dynamicTypeSize(.large...DynamicTypeSize.xxxLarge)
        .sensoryFeedback(.impact, trigger: store.isPlaying)
        .onAppear {
            send(.externalPlaybackStateChanged(audioStateObserver.isPlaying))
            withAnimation(.linear(duration: 100).repeatForever(autoreverses: false)) {
                time = 100
            }
        }
        .onChange(of: audioStateObserver.isPlaying) { _, newValue in
            send(.externalPlaybackStateChanged(newValue))
        }
        
    }
    
    private func triggerHaptic() {
#if os(iOS)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
#endif
    }
}

#Preview {
    let station = RadioStationEntity(id: 1,
                                     name: "Радио 1.FM",
                                     imagrUrl: URL(string: "https://radiopotok.ru/f/station/512/38.png")!,
                                     streamURL: URL(string: "https://strm112.1.fm/top40_mobile_mp3")!)
    NavigationStack {
        PlayerView(
            store: Store(
                initialState: PlayerReducer.State(station: station),
                reducer: { PlayerReducer() }
            )
        )
    }
}
