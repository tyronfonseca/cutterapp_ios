import SwiftUI

struct Main: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(AppSharedData.self) private var sharedData
    
    enum AppTab: Hashable {
        case search, cutterlist, settings, about
    }
    
    @State private var selectedTab: AppTab = .search
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // MARK: - Tab: Search Main Flow
            Tab(value: AppTab.search) {
                SearchView(sharedData: sharedData, context: viewContext)
            } label: {
                Label {
                    Text("Search")
                } icon: {
                    Image(systemName: "text.page.badge.magnifyingglass")
                        .environment(\.symbolVariants, .none)
                }
            }

            // MARK: - Tab: Cutter Table
            Tab(value: AppTab.cutterlist) {
                CutterTableView()
            } label: {
                Label {
                    Text("Cutter Table")
                } icon: {
                    Image(systemName: "list.bullet.rectangle.portrait")
                        .environment(\.symbolVariants, .none)
                }
            }

            // MARK: - Tab: About
            Tab(value: AppTab.about) {
                About()
            } label: {
                Label {
                    Text("about_btn")
                } icon: {
                    Image(systemName: "info.circle")
                        .environment(\.symbolVariants, .none)
                }
            }

            // MARK: - Tab: Settings
            Tab(value: AppTab.settings) {
                SettingsView()
            } label: {
                Label {
                    Text("settings")
                } icon: {
                    Image(systemName: "gear")
                        .environment(\.symbolVariants, .none)
                }
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .onReceive(NotificationCenter.default.publisher(for: .tabChangeNotification)) { notification in
            if let newTab = notification.userInfo?["tab"] as? Main.AppTab {
                selectedTab = newTab
            }
        }
    }
}

#Preview {
    Main().environment(AppSharedData())
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
