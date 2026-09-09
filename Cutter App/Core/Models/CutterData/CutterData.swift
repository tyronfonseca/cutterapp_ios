//
//  CutterData.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 1/9/26.
//

import Foundation

struct CutterData: Identifiable, Equatable {
    var id: UUID
    var name: String
    var code: String
    var authorName: String
    private(set) var _authorSurname: String
    var isbn: String
    var bookName: String
    var ddcs: [String]
    var ddcSelected: String
    var needsReview: Bool
    var dontSeparateName: Bool // Don't split the name and surname
    
    // Explicit initializer to keep memberwise signatures predictable across targets/previews
    init(
        id: UUID = UUID(),
        name: String,
        code: String,
        authorName: String = "",
        authorSurname: String = "",
        isbn: String = "",
        bookName: String = "",
        ddc: [String] = [],
        ddcSelected: String = "",
        needsReview: Bool = false,
        dontSeparateName: Bool = false
    ) {
        self.id = id
        self.name = name
        self.code = code
        self.authorName = authorName
        self._authorSurname = authorSurname
        self.isbn = isbn
        self.bookName = bookName
        self.ddcs = ddc
        self.ddcSelected = ddcSelected.isEmpty ? (ddc.first ?? "") : ddcSelected
        self.needsReview = needsReview
        self.dontSeparateName = dontSeparateName
    }
    
    var number: String {
        guard let firstLetter = name.first else {
            return code
        }
        return "\(firstLetter)\(code)".uppercased()
    }
    
    var cutterUsed: String {
        return "\(name):\(code)".uppercased()
    }
    
    var searchValue: String {
        if authorName.isEmpty || dontSeparateName {
            return authorSurname
        }
        
        return "\(authorSurname), \(authorName)"
    }
    
    // MARK: - Computed Properties with Public Getters and Setters
    
    var authorSurname: String {
        get {
            if self.dontSeparateName {
                let combined = "\(self.authorName) \(self._authorSurname)"
                return combined.trimmingCharacters(in: .whitespaces)
            }
            return self._authorSurname
        }
        set {
            self._authorSurname = newValue
        }
    }
    
}
