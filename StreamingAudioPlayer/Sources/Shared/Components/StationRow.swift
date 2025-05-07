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

            Text(station.name)
                .font(.headline)
            Spacer()
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
    VStack {
        StationRow(station: RadioStationEntity(id: UUID(),
                                               name: "Радио 1.FM",
                                               imagrUrl: URL(string:"https://radiopotok.ru/f/station/512/38.png")!,
                                               streamURL: URL(string: "https://strm112.1.fm/top40_mobile_mp3")!))
    }
}
