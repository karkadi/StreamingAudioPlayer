//
//  PlayButtonStyle.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import SwiftUI

/// Custom button style for play/pause/stop buttons.
struct PlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12)
            .background(configuration.isPressed ? .gray.opacity(0.3) : .accent)
            .clipShape(Circle())
            .foregroundStyle(.white)
            .containerShape(Circle())
            .animation(.easeInOut, value: configuration.isPressed)
    }
}
