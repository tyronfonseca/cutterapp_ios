//
//  SettingsView.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/5/24.
//

import SwiftUI
import CoreData

struct SettingsView: View {
    @Environment(AppSharedData.self) private var sharedData
    
    var body: some View {
        @Bindable var sharedData = sharedData
        NavigationStack {
            Form {
                Section (
                    footer: Text("Set to ON if you want the app to use the first name has the value to get the cutter number by default")
                ) {
                    Toggle("Author has no surname", isOn: $sharedData.dontSeparateName)
                        .toggleStyle(.switch)
                }
                
                Section(header: Text("Cutter table"),
                        footer: Text("You can add a custom cutter table. After adding the new table you can set it has the current table use by the app")) {
                    NavigationLink {
                        SelectCutterTableView()
                    } label: {
                        HStack {
                            Text("Active table")
                            Spacer()
                            Text(sharedData.currentTableSelected?.name ?? "Default")
                                .foregroundStyle(.secondary)
                        }
                    }
                    NavigationLink {
                        AddNewCutterTableView()
                    } label: {
                        Label("Add new cutter table", systemImage: "plus.circle")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.tint)
                    }
                }
                
                
                Section (
                    header: Text("Export to CSV"),
                    footer: Text("If you use the ISBN to get the cutter number, we can also get the book title and possible DDC numbers. This data comes from OpenLibrary.org")
                ) {
                    Toggle("Include DDC and Book title", isOn: $sharedData.includeExtrasInExport)
                        .toggleStyle(.switch)
                }
                
            }
            .navigationTitle("settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AppSharedData())
    }
}
