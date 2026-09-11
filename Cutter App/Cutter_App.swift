//
//  Cutter_AppApp.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

@main
struct Cutter_App: App {
    var persistenceController = PersistenceController.shared
    
    @State private var appSharedData = AppSharedData()
    
    init() {
        // Check if launching from XCUITest with the reset flag
        if CommandLine.arguments.contains("-resetData") {
            // Clear UserDefaults
            if let bundleID = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: bundleID)
            }
            
            // Use an in-memory Core Data stack to avoid persisting changes to disk
            persistenceController = PersistenceController(inMemory: true)
        } else {
            persistenceController = PersistenceController.shared
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Main()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(appSharedData)
                .environment(appSharedData.settings)
                .onAppear(){
                    // First time use
                    appSharedData.loadActiveTable(context: persistenceController.container.viewContext)
                }
                .onOpenURL { url in
                    if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                       let query = components.queryItems?.first(where: { $0.name == "query" })?.value {
                        // Open Search tab
                        NotificationCenter.default.post(
                            name: .tabChangeNotification,
                            object: nil,
                            userInfo: ["tab": Main.AppTab.search, "query": query]
                        )
                        
                        NotificationCenter.default.post(
                            name: .didReceiveShortcutSearch,
                            object: nil,
                            userInfo: ["query": query]
                        )
                    }
                }
        }
    }
}
