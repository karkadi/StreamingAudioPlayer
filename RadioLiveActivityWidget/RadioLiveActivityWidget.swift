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

        func placeholder(in context: Context) -> Entry {
            .placeholder
        }

        func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
            completion(.placeholder)
        }

        func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
            let isPlaying = UserDefaults.appGroup.bool(forKey: UserDefaultKey.isAudioPlaying)
            let entry = Entry(isPlaying: isPlaying)
            completion(.init(entries: [entry], policy: .never))
        }
    }
}

extension RadioLiveActivityWidget {
    struct Entry: TimelineEntry {
        var date: Date = .now
        var isPlaying: Bool
    }
}

extension RadioLiveActivityWidget.Entry {
    static var placeholder: Self {
        .init(isPlaying: false)
    }
}

struct AudioWidgetEntryView: View {

    var entry: RadioLiveActivityWidget.Entry

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
