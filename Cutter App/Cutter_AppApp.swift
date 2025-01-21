//
//  Cutter_AppApp.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

@main
struct Cutter_AppApp: App {
    @StateObject var mainScreenData = MainScreenModel()
    @StateObject private var searchesCDStack = SearchesCD.shared
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .environmentObject(mainScreenData)
                .environment(\.managedObjectContext,
                              searchesCDStack.persistentContainer.viewContext)
        }
    }
}
