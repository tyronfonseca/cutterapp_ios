//
//  OpenLibrarySearchResult.swift
//  Cutter App
//
//  Created by Tyron on 4/9/26.
//

import Foundation

struct OpenLibraryResponse: Codable {
    let numFound: Int
    let start: Int
    let numFoundExact: Bool
    let docs: [BookDoc]

    enum CodingKeys: String, CodingKey {
        case numFound, start, numFoundExact, docs
    }
}

struct BookDoc: Codable {
    let title: String?
    let authorName: [String]?
    let ddc: [String]?

    enum CodingKeys: String, CodingKey {
        case title
        case ddc
        case authorName = "author_name"
    }
}
