//
//  StationRow.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

import SwiftUI
import CachedAsyncImage

/// Reusable view for displaying a radio station.
struct StationRow: View {
    let station: RadioStationEntity
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void

    var body: some View {
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
            .shadow(radius: 4)

            Text(station.name)
                .font(.headline)
            Spacer()
            Button(action: onFavoriteToggle) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundStyle(isFavorite ? .yellow : .gray)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
            .accessibilityHint("Toggles favorite status for \(station.name)")
            Image(systemName: "radio")
                .symbolEffect(.pulse, isActive: true)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .contentMargins(.horizontal, 16)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(station.name)
    }
}

#Preview {
    let station = RadioStationEntity(id: 1,
                                     name: "Радио 1.FM",
                                     imagrUrl: URL(string: "https://radiopotok.ru/f/station/512/38.png")!,
                                     streamURL: URL(string: "https://strm112.1.fm/top40_mobile_mp3")!)
  VStack {
      StationRow(station: station, isFavorite: true, onFavoriteToggle: { })
      StationRow(station: station, isFavorite: false, onFavoriteToggle: { })
    }
}
