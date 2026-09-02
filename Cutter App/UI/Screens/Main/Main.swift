//
//  ContentView.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

struct Main: View {
    @EnvironmentObject var mainScreenData: MainViewModel
    @State private var selectedTab: AppTab = .home
    
    enum AppTab: Hashable {
        case home, scan, history, about
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab: Search Main Flow
            Tab("home", systemImage: "house", value: .home) {
                NavigationStack {
                    MainScreen()
                }
            }
            
            // MARK: - Tab: Scan
            Tab("scan_text", systemImage: "document.viewfinder", value: .scan) {
                NavigationStack {
                    OCRCameraView(
                        lastName: $mainScreenData.lastName,
                        firstName: $mainScreenData.firstName,
                        selectedTab: $selectedTab
                    )
                }
            }
            
            // MARK: - Tab: Search History
            Tab("history", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90", value: .history) {
                NavigationStack {
                    SearchHistory()
                }
            }
            
            // MARK: - Tab: About
            Tab("about_btn", systemImage: "info.circle", value: .about) {
                NavigationStack {
                    About()
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    Main()
        .environmentObject(MainViewModel())
}
