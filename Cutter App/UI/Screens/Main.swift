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
                    Text("search")
                } icon: {
                    Image(systemName: "text.page.badge.magnifyingglass")
                        .environment(\.symbolVariants, .none)
                }
                .accessibilityLabel(Text("search"))
                .accessibilityHint(Text("accesibility_search_hint"))
                .accessibilityIdentifier("tab.search")
                .accessibilityAddTraits(.isButton)
            }
            
            // MARK: - Tab: Cutter Table
            Tab(value: AppTab.cutterlist) {
                CutterTableView()
            } label: {
                Label {
                    Text("cutter_table")
                } icon: {
                    Image(systemName: "list.bullet.rectangle.portrait")
                        .environment(\.symbolVariants, .none)
                }
                .accessibilityLabel(Text("cutter_table"))
                .accessibilityHint(Text("accesibility_cutter_table_hint"))
                .accessibilityIdentifier("tab.cutterTable")
                .accessibilityAddTraits(.isButton)
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
                .accessibilityLabel(Text("about_btn"))
                .accessibilityHint(Text("accesibility_about_hint"))
                .accessibilityIdentifier("tab.about")
                .accessibilityAddTraits(.isButton)
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
                .accessibilityLabel(Text("settings"))
                .accessibilityHint(Text("accesibility_settings_hint"))
                .accessibilityIdentifier("tab.settings")
                .accessibilityAddTraits(.isButton)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text("accesibility_main_label"))
        .accessibilityHint(Text("accesibility_main_hint"))
        .accessibilityIdentifier("tabView.main")
        .accessibilityValue(Text(selectedTab == .search ?
                                 String(localized: "search") : selectedTab == .cutterlist ?
                                 String(localized: "cutter_table") : selectedTab == .about ?
                                 String(localized: "about") : String(localized: "settings")))
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
