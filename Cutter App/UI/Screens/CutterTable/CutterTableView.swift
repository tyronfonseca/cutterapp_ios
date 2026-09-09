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
            Group {
                if sharedData.currentCutterData.isEmpty {
                    ContentUnavailableView(
                        "No Cutter Data",
                        systemImage: "book.closed",
                        description: Text("Unable to load Cutter entries.")
                    )
                } else {
                    List {
                        ForEach(groupedCutters, id: \.key) { section in
                            Section(header: Text(section.key)) {
                                ForEach(section.value) { cutter in
                                    CutterRowView(cutter: cutter)
                                }
                            }
                            .sectionIndexLabel(Text(section.key))
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Cutter Table:")
            .toolbar {
                ToolbarItem(placement: .subtitle) {
                    Text("\(sharedData.currentTableSelected?.name ?? "")")
                        .font(.caption)
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        NavigationLink {
                            AddNewCutterTableView()
                        } label: {
                            Label("Add new table", systemImage: "plus.circle")
                        }
                        NavigationLink {
                            SelectCutterTableView()
                        } label: {
                            Label("Set current table", systemImage: "checkmark.circle")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .toolbarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search..."
            )
            .overlay {
                if !sharedData.currentCutterData.isEmpty && filteredCutters.isEmpty {
                    ContentUnavailableView.search(text: searchText)
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
