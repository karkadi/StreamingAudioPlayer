//
//  RadioLiveActivityAttributes.swift
//  StreamingAudioPlayer
//
//  Created by Arkadiy KAZAZYAN on 30/04/2025.
//

import ActivityKit

struct RadioLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var isPlaying: Bool
    }
    var stationName: String
}

extension RadioLiveActivityAttributes {
    static var preview: RadioLiveActivityAttributes {
        RadioLiveActivityAttributes(stationName: "Radio FM")
    }
}
