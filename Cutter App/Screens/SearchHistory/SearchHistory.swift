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
            List {
                ForEach(searchHistory, id: \.id) { result in
                    SearchResultItem(result: result)
                }
                .onDelete(perform: deleteItem)
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

//MARK: Previews
struct SearchResultItem : View {
    @ObservedObject var result : SearchResult
    
    private let dateFormatter : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    var body : some View {
        let resultStr = "\(result.last_name ?? ""), \(result.name ?? ""): \(result.calling_number ?? "") (\(result.name_selected ?? ""))"
        VStack (alignment: .leading) {
            Text(resultStr)
                .bold()
            Text("\(dateFormatter.string(from: result.last_searched ?? Date()))")
                .font(.caption)
        }
    }
}

struct SearchResultItem_Previews : PreviewProvider {
    static var previews: some View {
        Previewing(\.item) { item in
            SearchResultItem(result: item)
        }
    }
}
