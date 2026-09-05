//
//  CutterSearchEngine.swift
//  Cutter App
//
//  Created by Tyron on 5/9/26.
//

import Foundation

struct CutterSearchEngine {
    
    func search(queryName: String, queryLastName: String, in data: [CutterData], with dontSeparateName: Bool) -> CutterData? {
        guard !data.isEmpty else { return nil }

        let query = CutterHelper.getQueryFromName(name: queryName, lastName: queryLastName)

        var low = 0
        var high = data.count - 1
        var bestMatchIndex = 0

        while low <= high {
            let mid = (low + high) / 2
            let candidateName = CutterHelper.removeAccents(query: data[mid].name)
            let cmp = query.compare(candidateName)

            if cmp == .orderedSame {
                return data[mid]
            } else if cmp == .orderedAscending {
                high = mid - 1
            } else {
                bestMatchIndex = mid
                low = mid + 1
            }
        }

        var result = data[bestMatchIndex]
        result.dontSeparateName = dontSeparateName
        
        return result
    }
}
