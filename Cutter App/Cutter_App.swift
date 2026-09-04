//
//  Cutter_AppApp.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

@main
struct Cutter_App: App {
    
    var body: some Scene {
        WindowGroup {
            Main()
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
