//
//  VolumeLevelBar.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 29/04/2025.
//


// Sources/Shared/Components/VolumeLevelBar.swift
import SwiftUI

/// A view displaying animated volume level bars for playback indication.
struct VolumeLevelBar: View {
    let isPlaying: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<3) { index in
                Rectangle()
                    .frame(width: 4, height: isPlaying ? 16 : 4)
                    .foregroundStyle(.accent)
                    .animation(
                        animation(for: index),
                        value: isPlaying
                    )
            }
        }
    }

    private func animation(for index: Int) -> Animation {
        if isPlaying && !reduceMotion {
            return .easeInOut(duration: 0.5)
                .repeatForever(autoreverses: true)
                .delay(Double(index) * 0.1)
        }
        return .default
    }
}
