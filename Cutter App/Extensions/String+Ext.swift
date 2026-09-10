//
//  String+Ext.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import Foundation

extension StringProtocol {
    subscript(offset: Int) -> Character {
        let index = self.index(startIndex, offsetBy: offset)
        return self[index]
    }
    
    func compareToInsen(rightStr: String) -> Bool {
        self.lowercased() == rightStr.lowercased()
    }
}

extension String {
    /// Remove any accent. E.g., Ñ to N
    func removeAccents() -> String {
        return self.uppercased().folding(options: .diacriticInsensitive, locale: .current)
    }
    
    /// Extracts raw numeric ISBN-10 or ISBN-13 strings from text
    func extractISBNs() -> [String] {
        // Capture group 1 matches the digit sequence with hyphens/spaces
        let pattern = #"(?i)\b(?:ISBN(?:-1[03])?:?\s*)?((?:97[89][-\s]?)?(?:\d[-\s]?){9}[\dX])\b"#
        
        // Remove spaces that can come from scanning the IBSN barcode
        let copy = self.replacing(" ", with: "")
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsRange = NSRange(copy.startIndex..., in: copy)
        let matches = regex.matches(in: copy, range: nsRange)
        
        return matches.compactMap { match in
            // Extract Capture Group 1 (the number portion)
            guard let range = Range(match.range(at: 1), in: copy) else { return nil }
            let rawMatch = String(copy[range])
            
            // Strip hyphens and spaces to leave ONLY numbers (and 'X')
            let numberOnly = rawMatch.filter { $0.isNumber || $0.uppercased() == "X" }
            
            return numberOnly.isEmpty ? nil : numberOnly
        }
    }
    
    /// Returns the character range of a leading article if present.
    func leadingArticleRange(enabled: Bool) -> Range<String.Index>? {
        guard enabled else { return nil }
        
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        let pattern = #/^(the|unos|unas|uma|los|las|una|an|el|la|un|os|as|um|a|o)\s+/#.ignoresCase()
        
        // Use firstMatch(of:) instead of range(of:)
        return trimmed.firstMatch(of: pattern)?.range
    }
    
    /// Removes leading English, Spanish, or Portuguese articles.
    func strippingLeadingArticles(_ shouldIgnore: Bool) -> String {
        let trimmed = self.trimmingCharacters(in: .whitespaces)
        guard shouldIgnore, let range = trimmed.leadingArticleRange(enabled: true) else {
            return trimmed
        }
        return String(trimmed[range.upperBound...]).trimmingCharacters(in: .whitespaces)
    }
}
