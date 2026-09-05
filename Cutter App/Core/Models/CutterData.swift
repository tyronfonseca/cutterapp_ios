//
//  CutterData.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 1/9/26.
//

import Foundation

struct CutterData: Identifiable, Equatable, Hashable {
    var id: UUID
    var name: String
    var code: String
    private var _authorName: String
    private var _authorSurname: String
    var isbn: String
    var bookName: String
    var ddc: [String]
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
        needsReview: Bool = false,
        dontSeparateName: Bool = false
    ) {
        self.id = id
        self.name = name
        self.code = code
        self._authorName = authorName
        self._authorSurname = authorSurname
        self.isbn = isbn
        self.bookName = bookName
        self.ddc = ddc
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
        if authorName.isEmpty {
            return authorSurname
        }
        
        if dontSeparateName {
            return "\(authorName) \(authorSurname)"
        }
        return "\(authorSurname), \(authorName)"
    }
    
    // MARK: - Computed Properties with Public Getters and Setters
    
    var authorName: String {
        get {
            self.dontSeparateName ? "" : self._authorName
        }
        set {
            self._authorName = newValue
        }
    }
    
    var authorSurname: String {
        get {
            if self.dontSeparateName {
                let combined = "\(self._authorName) \(self._authorSurname)"
                return combined.trimmingCharacters(in: .whitespaces)
            }
            return self._authorSurname
        }
        set {
            self._authorSurname = newValue
        }
    }
    
    // MARK: - Equatable & Hashable Conformance
    
    static func == (lhs: CutterData, rhs: CutterData) -> Bool {
        return lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.code == rhs.code &&
        lhs._authorName == rhs._authorName &&
        lhs._authorSurname == rhs._authorSurname &&
        lhs.isbn == rhs.isbn &&
        lhs.bookName == rhs.bookName &&
        lhs.ddc == rhs.ddc &&
        lhs.needsReview == rhs.needsReview &&
        lhs.dontSeparateName == rhs.dontSeparateName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(code)
        hasher.combine(_authorName)
        hasher.combine(_authorSurname)
        hasher.combine(isbn)
        hasher.combine(bookName)
        hasher.combine(ddc)
        hasher.combine(needsReview)
        hasher.combine(dontSeparateName)
    }
}
