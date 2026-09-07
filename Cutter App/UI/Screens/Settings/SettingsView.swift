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
    @State private var cutterExample = CutterData(
        name: "Borg",
        code: "732",
        authorName: "Jorge Luis",
        authorSurname: "Borges",
        bookName: "Ficciones"
    )
    
    var body: some View {
        @Bindable var sharedData = sharedData
        @Bindable var settings = sharedData.settings
        
        NavigationStack {
            Form {
                // MARK: - Cutter Table Selection
                Section(
                    header: Text("Cutter table"),
                    footer: Text("You can add a custom cutter table. After adding the new table, you can set it as the current table used by the app.")
                ) {
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
                
                // MARK: - Search Behavior Settings
                Section(
                    header: Text("Search Behavior"),
                    footer: Text("Set to ON if you want the app to treat the complete name string as a single entity rather than splitting author name and surname.")
                ) {
                    Toggle("Author has no surname", isOn: $settings.dontSeparateName)
                        .toggleStyle(.switch)
                }
                
                Section {
                    Toggle("Ignore grammar articles", isOn: $settings.ignoreArticles)
                        .toggleStyle(.switch)
                    Toggle("Spell Mc and M' as Mac", isOn: $settings.useFormatMac)
                        .toggleStyle(.switch)
                }
                
                // MARK: - Preview Section
                Section(
                    header: Text("Cutter generation"),
                    footer: Text("This is a live preview demonstrating your current call number configuration.")
                ) {
                    SearchItemView(item: cutterExample)
                }
                
                // MARK: - Call Number Formatting (Prefix & Suffix)
                Section(
                    header: Text("Call Number Formatting"),
                    footer: Text("Configure what information and character length to append before and after the cutter number.")
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cutter Prefix")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Picker("Cutter prefix", selection: $settings.textBeforeNum) {
                            Text("Author").tag(TextBeforeAfterNum.authorSurname)
                            Text("Title").tag(TextBeforeAfterNum.title)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                    
                    Stepper(value: $settings.charsBeforeNum, in: 0...7) {
                        HStack {
                            Text("Prefix length")
                            Spacer()
                            Text("\(settings.charsBeforeNum) char\(settings.charsBeforeNum == 1 ? "" : "s")")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cutter Suffix")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Picker("Cutter suffix", selection: $settings.textAfterNum) {
                            Text("Author").tag(TextBeforeAfterNum.authorSurname)
                            Text("Title").tag(TextBeforeAfterNum.title)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                    
                    Stepper(value: $settings.charsAfterNum, in: 0...7) {
                        HStack {
                            Text("Suffix length")
                            Spacer()
                            Text("\(settings.charsAfterNum) char\(settings.charsAfterNum == 1 ? "" : "s")")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // MARK: - Export Settings
                Section(
                    header: Text("Save to CSV"),
                    footer: Text("If you use ISBN numbers during cutter resolution, supplementary metadata (Title, DDC classification) will be attached to the CSV file via OpenLibrary.org.")
                ) {
                    Toggle("Include DDC and Title", isOn: $settings.includeExtrasInExport)
                        .toggleStyle(.switch)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let sharedData = AppSharedData()
    
    return SettingsView()
        .environment(sharedData)
        .environment(sharedData.settings)
}
