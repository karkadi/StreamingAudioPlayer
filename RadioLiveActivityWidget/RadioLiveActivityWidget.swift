//
//  RadioLiveActivityWidget.swift
//  RadioLiveActivityWidget
//
//  Created by Arkadiy KAZAZYAN on 30/04/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RadioLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RadioLiveActivityAttributes.self) { context in
            LockScreenView(stationName: context.attributes.stationName, isPlaying: context.state.isPlaying)
                .activityBackgroundTint(.black.opacity(0.8))
                .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.stationName)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Link(destination: URL(string: "radiostreaming://playpause")!) {
                        Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                            .foregroundStyle(.white)
                    }
                    .accessibilityLabel(context.state.isPlaying ? "Pause" : "Play")

//                    Button(action: {
//                        Task {
//                            let url = URL(string: "radiostreaming://playpause")!
//                            await UIApplication.shared.open(url)
//                        }
//                    }) {
//                        Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
//                            .foregroundStyle(.white)
//                    }
//                    .accessibilityLabel(context.state.isPlaying ? "Pause" : "Play")
                }
            } compactLeading: {
                Image(systemName: context.state.isPlaying ? "play.fill" : "pause.fill")
                    .foregroundStyle(.white)
            } compactTrailing: {
                Text(context.attributes.stationName)
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            } minimal: {
                Image(systemName: context.state.isPlaying ? "play.fill" : "pause.fill")
                    .foregroundStyle(.white)
            }
        }
    }
}

private struct LockScreenView: View {
    let stationName: String
    let isPlaying: Bool

    var body: some View {
        HStack {
            Image(systemName: isPlaying ? "play.fill" : "pause.fill")
                .foregroundStyle(.white)
            Text(stationName)
                .font(.subheadline)
                .foregroundStyle(.white)
                .lineLimit(1)
            Spacer()
            Link(destination: URL(string: "radiostreaming://playpause")!) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .foregroundStyle(.white)
            }
            .accessibilityLabel(isPlaying ? "Pause" : "Play")

//            Button(action: {
//                Task {
//                    let url = URL(string: "radiostreaming://playpause")!
//                    await UIApplication.shared.open(url)
//                }
//            }) {
//                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
//                    .foregroundStyle(.white)
//            }
//            .accessibilityLabel(isPlaying ? "Pause" : "Play")
        }
        .padding()
        .background(.black.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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



/*
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct RadioLiveActivityWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Emoji:")
            Text(entry.emoji)
        }
    }
}

struct RadioLiveActivityWidget: Widget {
    let kind: String = "RadioLiveActivityWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                RadioLiveActivityWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                RadioLiveActivityWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    RadioLiveActivityWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
*/
