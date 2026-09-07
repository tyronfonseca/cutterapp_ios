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

        let query = CutterHelper.getCutterQuery(name: queryName, lastName: queryLastName, dontSeparateName: dontSeparateName)

        var low = 0
        var high = data.count - 1
        var bestMatchIndex = 0

        while low <= high {
            let mid = (low + high) / 2
            let candidateName = data[mid].name.removeAccents()
            
            let queryPrefix = String(query.prefix(candidateName.count))
            let cmp = queryPrefix.compare(candidateName, options: [.caseInsensitive, .diacriticInsensitive])

            if cmp == .orderedSame {
                bestMatchIndex = mid
                low = mid + 1
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
