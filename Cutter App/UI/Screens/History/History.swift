//
//  SearchHistory.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 21/1/25.
//

import SwiftUI

struct SearchHistory: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: SearchesCD.fetchAllSearchResults())
    private var searchHistory: FetchedResults<SearchResult>
    
    var body: some View {
        NavigationStack {
            if searchHistory.isEmpty {
                ContentUnavailableView(
                    "history_empty",
                    systemImage: "book.closed.fill",
                    description: Text("history_empty_description")
                )
            } else {
                List {
                    ForEach(searchHistory, id: \.id) { result in
                        SearchResultItem(result: result)
                    }
                    .onDelete(perform: deleteItem)
                }
            }
        }
        .navigationTitle("search_history_title")
    }
    
    func deleteItem(at offsets: IndexSet) {
        for offset in offsets {
            SearchesCD.shared.delete(search: searchHistory[offset])
        }
    }
}
