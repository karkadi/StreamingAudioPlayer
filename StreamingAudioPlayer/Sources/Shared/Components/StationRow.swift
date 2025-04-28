//
//  StationRow.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 28/04/2025.
//

// Sources/Shared/Components/StationRow.swift
import SwiftUI

/// Reusable view for displaying a radio station.
struct StationRow: View {
    let station: RadioStationEntity

    var body: some View {
        HStack {
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
        StationRow(station: RadioStationEntity(id: UUID(), name: "France Inter", streamURL: URL(string: "https://icecast.radiofrance.fr/franceinter-hifi.aac")!))
    }
}
