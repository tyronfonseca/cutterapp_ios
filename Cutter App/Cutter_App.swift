//
//  Cutter_AppApp.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

@main
struct Cutter_App: App {
    @StateObject var mainScreenData = MainViewModel()
    @StateObject private var searchesCDStack = SearchesCD.shared
    
    var body: some Scene {
        WindowGroup {
            Main()
                .environmentObject(mainScreenData)
                .environment(\.managedObjectContext,
                              searchesCDStack.persistentContainer.viewContext)
        }
    }
}
