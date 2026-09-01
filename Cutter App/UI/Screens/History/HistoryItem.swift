//
//  HistoryItem.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 1/9/26.
//

import SwiftUI

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
