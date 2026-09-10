//
//  SearchOptions.swift
//  Cutter App
//
//  Created by Tyron on 10/9/26.
//

enum SearchFilterOption: String, CaseIterable, Identifiable {
    case all
    case needsReview
    case reviewed
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .all:
            return String(localized: "filter_all")
        case .needsReview:
            return String(localized: "filter_needs_review")
        case .reviewed:
            return String(localized: "filter_reviewed")
        }
    }
}

enum SearchSortOption: String, CaseIterable, Identifiable {
    case newest
    case oldest
    case author
    
    var id: String { rawValue }
    
    var localizedName: String {
        switch self {
        case .newest:
            return String(localized: "filter_newest_first")
        case .oldest:
            return String(localized: "filter_oldest_first")
        case .author:
            return String(localized: "filter_author")
        }
    }
}
