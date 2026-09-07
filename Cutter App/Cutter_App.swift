//
//  Cutter_AppApp.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

@main
struct Cutter_App: App {
    let persistenceController = PersistenceController.shared
    
    @State private var appSharedData = AppSharedData()
    
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
