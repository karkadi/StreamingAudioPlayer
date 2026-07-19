//
//  StationFormView.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 19/07/2026.
//

import ComposableArchitecture
import SwiftUI

/// Sheet form for adding a new radio station or editing an existing one.
@ViewAction(for: StationFormReducer.self)
struct StationFormView: View {
    @Bindable var store: StoreOf<StationFormReducer>

    var body: some View {
        NavigationStack {
            Form {
                Section("Station Details") {
                    TextField("Name", text: $store.name)
                        .autocorrectionDisabled()
                        .accessibilityLabel("Station name")

                    TextField("Image URL", text: $store.imageUrlString)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
#if os(iOS)
                        .keyboardType(.URL)
#endif
                        .accessibilityLabel("Station image URL")

                    TextField("Stream URL", text: $store.streamUrlString)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
#if os(iOS)
                        .keyboardType(.URL)
#endif
                        .accessibilityLabel("Station stream URL")
                }

                if let errorMessage = store.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .accessibilityLabel("Error: \(errorMessage)")
                    }
                }
            }
            .navigationTitle(store.navigationTitle)
#if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        send(.cancelTapped)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        send(.saveTapped)
                    }
                }
            }
        }
    }
}

#Preview {
    StationFormView(
        store: Store(initialState: StationFormReducer.State(mode: .add)) {
            StationFormReducer()
        }
    )
}
