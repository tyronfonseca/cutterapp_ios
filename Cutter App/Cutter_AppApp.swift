//
//  Cutter_AppApp.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

@main
struct Cutter_AppApp: App {
    var mainScreenData = MainScreenModel()
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .environmentObject(mainScreenData)
        }
    }
}
