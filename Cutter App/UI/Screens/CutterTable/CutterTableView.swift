//
//  CutterTableView.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import SwiftUI

struct CutterTableView: View {
    @Environment(AppSharedData.self) private var sharedData
    
    @State private var searchText: String = ""
    
    // MARK: - Filtered Cutters
    private var filteredCutters: [CutterData] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let sourceData = sharedData.currentCutterData
        
        guard !query.isEmpty else { return sourceData }
        
        return sourceData.filter { item in
            item.name.lowercased().contains(query) ||
            item.code.lowercased().contains(query) ||
            item.number.lowercased().contains(query) ||
            item.bookName.lowercased().contains(query) ||
            item.isbn.contains(query)
        }
    }
    
    // MARK: - Grouped Cutters (Alphabetical Sections)
    private var groupedCutters: [(key: String, value: [CutterData])] {
        let groups = Dictionary(grouping: filteredCutters) { item in
            let trimmedName = item.name.trimmingCharacters(in: .whitespaces)
            guard let firstLetter = trimmedName.first?.uppercased(),
                  firstLetter.rangeOfCharacter(from: .letters) != nil else {
                return "#"
            }
            return firstLetter
        }
        
        return groups.sorted { lhs, rhs in
            if lhs.key == "#" { return false }
            if rhs.key == "#" { return true }
            return lhs.key < rhs.key
        }
    }
    
    var body: some View {
        NavigationStack {
            // Accessibility: Identify the Cutter Table screen
            EmptyView()
                .accessibilityHidden(true)
            
            Group {
                if sharedData.currentCutterData.isEmpty {
                    ContentUnavailableView(
                        String(localized: "cuttertable_no_data"),
                        systemImage: "book.closed",
                        description: Text(String(localized: "cuttertable_unable_to_load"))
                    )
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("cutterTable.emptyState")
                } else {
                    List {
                        ForEach(groupedCutters, id: \.key) { section in
                            Section(header: Text(section.key)) {
                                ForEach(section.value) { cutter in
                                    let hint = cutter.bookName.isEmpty ? String(localized: "cutter_row_hint_no_book") : String(localized: .cutterRowHint(cutter.bookName))
                                    CutterRowView(cutter: cutter)
                                        .accessibilityElement(children: .combine)
                                        .accessibilityLabel(Text(cutter.name))
                                        .accessibilityValue(Text(cutter.number))
                                        .accessibilityHint(Text(hint))
                                        .accessibilityIdentifier("cutterTableRow.\(cutter.code)")
                                }
                            }
                            .sectionIndexLabel(Text(section.key))
                        }
                    }
                    .accessibilityLabel(Text("cuttertable_list_label"))
                    .accessibilityHint(Text("cuttertable_list_hint"))
                    .accessibilityIdentifier("cutterTable.list")
                    .listStyle(.plain)
                }
            }
            .navigationTitle(String(localized: "cuttertable_nav_title"))
            .accessibilityIdentifier("cutterTable.screen")
            .toolbar {
                ToolbarItem(placement: .subtitle) {
                    Text("\(sharedData.currentTableSelected?.name ?? "")")
                        .font(.caption)
                        .accessibilityIdentifier("cutterTable.currentTableName")
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {                        
                        NavigationLink {
                            SelectCutterTableView()
                        } label: {
                            Label(String(localized: "cuttertable_set_current_table"), systemImage: "checkmark.circle")
                                .accessibilityIdentifier("cutterTable.action.setCurrent")
                        }
                        NavigationLink {
                            AddNewCutterTableView()
                        } label: {
                            Label(String(localized: "cuttertable_add_new_table"), systemImage: "plus.circle")
                                .accessibilityIdentifier("cutterTable.action.addNew")
                        }
                    } label: {
                        Label("more_actions", systemImage: "ellipsis")
                    }
                    .accessibilityIdentifier("cutterTable.moreActions")
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: String(localized: "cuttertable_search_prompt")
            )
            .accessibilityIdentifier("cutterTable.searchField")
            .overlay {
                if !sharedData.currentCutterData.isEmpty && filteredCutters.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel(Text("no_results"))
                        .accessibilityIdentifier("cutterTable.noResults")
                }
            }
        }
    }
}

// MARK: - Row Component
private struct CutterRowView: View {
    let cutter: CutterData
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(cutter.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                if !cutter.bookName.isEmpty {
                    Text(cutter.bookName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer(minLength: 8)
            
            // Cutter Number Badge
            Text(cutter.number)
                .font(.callout)
                .monospaced()
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.accentColor.opacity(0.12))
                .foregroundStyle(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 2)
        .textSelection(.enabled)
    }
}

#Preview {
    CutterTableView()
        .environment(AppSharedData())
}

