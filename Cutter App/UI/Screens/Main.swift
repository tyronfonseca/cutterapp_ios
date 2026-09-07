//
//  ContentView.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

struct Main: View {
    @Environment(AppSharedData.self) private var sharedData
    @State private var selectedTab: AppTab = .search
    
    enum AppTab: Hashable {
        case search, cutterlist, settings, about
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab: Search Main Flow
            Tab("Search", systemImage: "text.page.badge.magnifyingglass", value: .search) {
                SearchView(sharedData: sharedData)
            }
            
            // MARK: - Tab: Cutter Table
            Tab("Cutter Table", systemImage: "list.bullet.rectangle.portrait", value: .cutterlist) {
                CutterTableView()
            }
            
            // MARK: - Tab: About
            Tab("about_btn", systemImage: "info.circle", value: .about) {
                About()
            }
            
            // MARK: - Tab: Settings
            Tab("settings", systemImage: "gear", value: .settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    Main().environment(AppSharedData())
}
