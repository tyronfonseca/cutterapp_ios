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
                    header: Text(String(localized: "cutter_table")),
                    footer: Text(String(localized: "settings_cutterTable_footer"))
                ) {
                    NavigationLink {
                        SelectCutterTableView()
                    } label: {
                        HStack {
                            Text(String(localized: "settings_cutterTable_activeTable"))
                            Spacer()
                            Text(sharedData.currentTableSelected?.name ?? String(localized: "settings_cutterTable_defaultName"))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    NavigationLink {
                        AddNewCutterTableView()
                    } label: {
                        Label(String(localized: "settings_cutterTable_add"), systemImage: "plus.circle")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.tint)
                    }
                }                
                
                // MARK: - Search Behavior Settings
                Section(
                    header: Text(String(localized: "settings_searchBehavior_header")),
                    footer: Text(String(localized: "settings_searchBehavior_footer"))
                ) {
                    Toggle(String(localized: "settings_searchBehavior_noSurname"), isOn: $settings.dontSeparateName)
                        .toggleStyle(.switch)
                }
                
                Section {
                    Toggle(String(localized: "settings_searchBehavior_ignoreArticles"), isOn: $settings.ignoreArticles)
                        .toggleStyle(.switch)
                    Toggle(String(localized: "settings_searchBehavior_spellAsMac"), isOn: $settings.useFormatMac)
                        .toggleStyle(.switch)
                }
                
                // MARK: - Preview Section
                Section(
                    header: Text(String(localized: "settings_preview_header")),
                    footer: Text(String(localized: "settings_preview_footer"))
                ) {
                    SearchItemView(item: cutterExample)
                }
                
                // MARK: - Number Formatting (Prefix & Suffix)
                Section(
                    header: Text(String(localized: "settings_number_header")),
                    footer: Text(String(localized: "settings_number_footer"))
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "settings_number_prefix"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Picker(String(localized: "settings_number_prefix"), selection: $settings.textBeforeNum) {
                            Text(String(localized: "author")).tag(TextBeforeAfterNum.authorSurname)
                            Text(String(localized: "title")).tag(TextBeforeAfterNum.title)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                    
                    Stepper(value: $settings.charsBeforeNum, in: 0...7) {
                        HStack {
                            Text(String(localized: "settings_number_prefix_length"))
                            Spacer()
                            Text(String(localized: "settings_common_charsCount", defaultValue: "\(settings.charsBeforeNum) letter\(settings.charsBeforeNum == 1 ? "" : "s")"))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "settings_number_suffix"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Picker(String(localized: "settings_number_suffix"), selection: $settings.textAfterNum) {
                            Text(String(localized: "author")).tag(TextBeforeAfterNum.authorSurname)
                            Text(String(localized: "title")).tag(TextBeforeAfterNum.title)
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                    
                    Stepper(value: $settings.charsAfterNum, in: 0...7) {
                        HStack {
                            Text(String(localized: "settings_number_suffix_length"))
                            Spacer()
                            Text(String(localized: "settings_common_charsCount", defaultValue: "\(settings.charsAfterNum) letter\(settings.charsAfterNum == 1 ? "" : "s")"))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // MARK: - Export Settings
                Section(
                    header: Text(String(localized: "settings_export_header")),
                    footer: Text(String(localized: "settings_export_footer"))
                ) {
                    Toggle(String(localized: "settings_export_includeExtras"), isOn: $settings.includeExtrasInExport)
                        .toggleStyle(.switch)
                }
            }
            .navigationTitle(String(localized: "settings"))
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
