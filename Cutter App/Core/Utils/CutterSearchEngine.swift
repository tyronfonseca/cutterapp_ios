//
//  CutterSearchEngine.swift
//  Cutter App
//
//  Created by Tyron on 5/9/26.
//

import Foundation

struct CutterSearchEngine {
    
    static func search(
        queryName: String,
        queryLastName: String,
        in data: [CutterData],
        options: CutterSearchOptions
    ) -> CutterData? {
        guard !data.isEmpty else { return nil }
        
        let query = getCutterQuery(
            name: queryName,
            lastName: queryLastName,
            options: options
        )
        
        var low = 0
        var high = data.count - 1
        var bestMatchIndex = 0

        while low <= high {
            let mid = (low + high) / 2
            let candidateName = data[mid].name.removeAccents()
            
            let cmp = query.compare(candidateName, options: [.caseInsensitive, .diacriticInsensitive])
            
            if cmp == .orderedSame {
                bestMatchIndex = mid
                break
            } else if cmp == .orderedDescending {
                bestMatchIndex = mid
                low = mid + 1
            } else {
                high = mid - 1
            }
        }
        
        var result = data[bestMatchIndex]
        result.dontSeparateName = options.dontSeparateName
        return result
    }
    
    private static func getCutterQuery(
        name: String,
        lastName: String,
        options: CutterSearchOptions
    ) -> String {
        let _name = name.trimmingCharacters(in: .whitespaces)
        let _lastName = lastName.trimmingCharacters(in: .whitespaces)
        
        var result = options.dontSeparateName ? "\(_name) \(_lastName)" : "\(_lastName), \(_name)"
        
        // Strip leading articles if enabled
        if options.ignoreArticles, let articleRange = result.leadingArticleRange(enabled: true) {
            result.removeSubrange(articleRange)
        }
        
        // Format Mc/M' prefix rules
        if options.useFormatMac {
            result = result.replacing(#/^M[c']\.?/#, with: "Mac")
        }
        
        return result.removeAccents().trimmingCharacters(in: .whitespaces)
    }
}
