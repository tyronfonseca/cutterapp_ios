//
//  SearchOptions.swift
//  Cutter App
//
//  Created by Tyron on 10/9/26.
//
protocol SearchOptionSelectable: Identifiable, Hashable, CaseIterable where AllCases: RandomAccessCollection {
    var localizedName: String { get }
    var accessibilityID: String { get }
    var id : String { get }
}

enum SearchFilterOption: String, CaseIterable, Identifiable, SearchOptionSelectable {
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
    
    var accessibilityID: String {
        "search_filter_by_\(id)"
    }
}

enum SearchSortOption: String, CaseIterable, Identifiable, SearchOptionSelectable {
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
    
    var accessibilityID: String {
        "search_sort_by_\(id)"
    }
}
