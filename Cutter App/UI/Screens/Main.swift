//
//  ContentView.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import SwiftUI

struct Main: View {
    @State private var selectedTab: AppTab = .search
    
    enum AppTab: Hashable {
        case search, cutterlist, about
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab: Search Main Flow
            Tab("home", systemImage: "book", value: .search) {
                SearchView()
            }
            
            // MARK: - Tab: About
            Tab("Cutter List", systemImage: "list.bullet.rectangle.portrait", value: .cutterlist) {
                CutterListView()
            }
            
            // MARK: - Tab: About
            Tab("about_btn", systemImage: "info.circle", value: .about) {
                About()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
    }
}

#Preview {
    Main()
}
