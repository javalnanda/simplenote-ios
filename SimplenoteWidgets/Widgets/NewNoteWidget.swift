//
//  SwiftUIView.swift
//  Simplenote
//
//  Created by Charlie Scheer on 5/26/21.
//  Copyright © 2021 Automattic. All rights reserved.
//

import SwiftUI
import WidgetKit

@available(iOS 14.0, *)
struct NewNoteWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Constants.configurationKind, provider: NewNoteTimelineProvider()) { entry in
            NewNoteWidgetView()
        }
        .configurationDisplayName(Constants.displayName)
        .description(Constants.description)
        .supportedFamilies([.systemSmall])

    }
}

private struct Constants {
    static let configurationKind = "NewNoteWidget"
    static let displayName = "New Note"
    static let description = "Create a new note instantly with one tap."
}
