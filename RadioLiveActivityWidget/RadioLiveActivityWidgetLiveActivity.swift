//
//  RadioLiveActivityWidgetLiveActivity.swift
//  RadioLiveActivityWidget
//
//  Created by Arkadiy KAZAZYAN on 30/04/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RadioLiveActivityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RadioLiveActivityAttributes.self) { context in
            // Lock Screen / Dynamic Island UI
            VStack {
                Text(context.attributes.stationName)
                    .font(.subheadline)
                Button(intent: AudioPlaybackWidgetPauseIntent()) {
               // Button(intent: AudioControlIntent(action: context.state.isPlaying ? .stop : .play)) {
                    Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.plain)
            }
            .padding()
            .activityBackgroundTint(.black)
            .activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            // Dynamic Island configuration
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.attributes.stationName)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Button(intent: AudioPlaybackWidgetPauseIntent()) {
                   //
                 //   Button(intent: AudioControlIntent(action: context.state.isPlaying ? .stop : .play)) {
                        Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
                    }
                }
            } compactLeading: {
                Text(context.attributes.stationName)
            } compactTrailing: {
                Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
            } minimal: {
                Image(systemName: context.state.isPlaying ? "pause.fill" : "play.fill")
            }
        }
    }
}

#Preview("Notification", as: .content, using: RadioLiveActivityAttributes.preview) {
    RadioLiveActivityWidgetLiveActivity()
} contentStates: {
    RadioLiveActivityAttributes.ContentState.init(isPlaying: true)
    RadioLiveActivityAttributes.ContentState.init(isPlaying: false)
}
