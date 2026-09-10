//
//  SearchCutterIntent.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import AppIntents
import SwiftUI

struct SearchCutterIntent: AppIntent {
    static var title: LocalizedStringResource = "Search in Cutter"
    static var description = IntentDescription("Searches selected text in the Cutter app.")
    
    static var openAppWhenRun: Bool = true
    
    // Make it appear in more contexts
    static var isDiscoverable: Bool = true

    @Parameter(title: "Search Query", description: "Text to search")
    var query: String

    @MainActor
    func perform() async throws -> some IntentResult {
        NotificationCenter.default.post(
            name: .didReceiveShortcutSearch,
            object: nil,
            userInfo: ["query": query]
        )
        return .result()
    }
}
// MARK: - App Shortcuts Provider
struct CutterShortcutProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: SearchCutterIntent(),
            phrases: [
                "Search in \(.applicationName)",
                "Look up Cutter in \(.applicationName)",
                "Search ISBN in \(.applicationName)"
            ],
            shortTitle: "Search in Cutter",
            systemImageName: "magnifyingglass"
        )
    }
    
    static var shortcutTileColor: ShortcutTileColor = .purple
}

// MARK: - Notification Extension
extension Notification.Name {
    static let didReceiveShortcutSearch = Notification.Name("didReceiveShortcutSearch")
    static let tabChangeNotification = Notification.Name("tabChangeNotification")
}
