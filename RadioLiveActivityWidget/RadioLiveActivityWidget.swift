//
//  RadioLiveActivityWidget.swift
//  RadioLiveActivityWidget
//
//  Created by Arkadiy KAZAZYAN on 30/04/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI
import AppIntents

extension RadioLiveActivityWidget {
    struct Provider: TimelineProvider {
        typealias Entry = SoundsEntry
        func placeholder(in context: Context) -> Entry {
            .placeholder
        }

        func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
            completion(.placeholder)
        }

        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
            let isPlaying = UserDefaults.appGroup.bool(forKey: UserDefaultKey.isAudioPlaying)
            let currentStationName = UserDefaults.appGroup.string(forKey: UserDefaultKey.currentStationName)
            let currentStationUrl = UserDefaults.appGroup.string(forKey: UserDefaultKey.currentStationUrl)

            let entry = Entry(isPlaying: isPlaying,
                              currentStationName: currentStationName,
                              currentStationUrl: currentStationUrl)
            completion(.init(entries: [entry], policy: .never))
        }
    }
}

extension RadioLiveActivityWidget {
    struct SoundsEntry: TimelineEntry {
        var date: Date = .now
        var isPlaying: Bool
        var currentStationName: String?
        var currentStationUrl: String?
    }
}

extension RadioLiveActivityWidget.SoundsEntry {
    static var placeholder: Self {
        .init(isPlaying: false)
    }
}

struct AudioWidgetEntryView: View {

    var entry: RadioLiveActivityWidget.SoundsEntry

    var body: some View {
        VStack {
            Text(entry.isPlaying ? "Playing" : "Paused")
                .font(.headline)

            Button(intent: AudioControlIntent(action: entry.isPlaying ? .stop : .play)) {
                Image(systemName: entry.isPlaying ? "pause.fill" : "play.fill")
            }
            .buttonStyle(.plain)
            Button(intent: AudioControlIntent(action: .stop)) {
                Image(systemName: "pause.fill" )
            }
            .buttonStyle(.plain)
        }
    }
}

struct RadioLiveActivityWidget: Widget {
    let kind: String = "RadioLiveActivityWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            AudioWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// dynamic Island Preview
#Preview("Notification",
         as: .dynamicIsland(.minimal),
         using: RadioLiveActivityAttributes.preview) {
    RadioLiveActivityWidget()
} contentStates: {
    RadioLiveActivityAttributes.ContentState.init(isPlaying: true)
    RadioLiveActivityAttributes.ContentState.init(isPlaying: false)
}
