//
//  CutterListView.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import SwiftUI

struct CutterListView: View {
    private let cutterGetter = CutterGetter.shared
        
        @State private var allCutters: [CutterData] = []
        @State private var searchText: String = ""
        
        // Standard A-Z alphabet array
        private let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".map { String($0) }
        
        // 1. Filter cutters
        private var filteredCutters: [CutterData] {
            let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            guard !query.isEmpty else { return allCutters }
            
            return allCutters.filter { item in
                item.name.lowercased().contains(query) ||
                item.code.lowercased().contains(query) ||
                item.number.lowercased().contains(query) ||
                item.bookName.lowercased().contains(query) ||
                item.isbn.contains(query)
            }
        }
        
        // 2. Group items by their starting letter while preserving section ordering
        private var groupedCutters: [(key: String, value: [CutterData])] {
            let groups = Dictionary(grouping: filteredCutters) { item in
                let name = item.name.isEmpty ? item.searchValue : item.name
                guard let firstLetter = name.trimmingCharacters(in: .whitespaces).first?.uppercased(),
                      firstLetter.rangeOfCharacter(from: .letters) != nil else {
                    return "#"
                }
                return firstLetter
            }
            
            // Sort sections alphabetically ('#' goes to the end)
            return groups.sorted { lhs, rhs in
                if lhs.key == "#" { return false }
                if rhs.key == "#" { return true }
                return lhs.key < rhs.key
            }
        }
        
        var body: some View {
            NavigationStack {
                ScrollViewReader { proxy in
                    HStack(spacing: 0) {
                        List {
                            ForEach(groupedCutters, id: \.key) { section in
                                Section(header: Text(section.key).id(section.key)) {
                                    ForEach(section.value) { cutter in
                                        CutterRowView(cutter: cutter)
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                        
                        // Alphabet Sidebar Index
                        if searchText.isEmpty {
                            VStack(spacing: 2) {
                                ForEach(alphabet, id: \.self) { letter in
                                    Button(action: {
                                        withAnimation {
                                            proxy.scrollTo(letter, anchor: .top)
                                        }
                                    }) {
                                        Text(letter)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(.tint)
                                            .frame(width: 20, height: 16)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.trailing, 4)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search author or number...")

                .navigationTitle("Cutter Table")
                .overlay {
                    if filteredCutters.isEmpty && !allCutters.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    }
                }
                .onAppear {
                    if allCutters.isEmpty {
                        allCutters = cutterGetter.getCutterData()
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
                Text(cutter.name.isEmpty ? cutter.searchValue : cutter.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
            
            // Cutter Number Badge
            Text(cutter.number)
                .font(.callout)
                .fontDesign(.monospaced)
                .fontWeight(.bold)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.accentColor.opacity(0.12))
                .foregroundStyle(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    CutterListView()
}
