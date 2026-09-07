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
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsRange = NSRange(self.startIndex..., in: self)
        let matches = regex.matches(in: self, range: nsRange)
        
        return matches.compactMap { match in
            // Extract Capture Group 1 (the number portion)
            guard let range = Range(match.range(at: 1), in: self) else { return nil }
            let rawMatch = String(self[range])
            
            // Strip hyphens and spaces to leave ONLY numbers (and 'X')
            let numberOnly = rawMatch.filter { $0.isNumber || $0.uppercased() == "X" }
            
            return numberOnly.isEmpty ? nil : numberOnly
        }
    }
    
    /// Remove leading articles (grammar). Ther articles could be in English, Spanish or Portuguese.
    func strippingLeadingArticles(shouldIgnore: Bool) -> String {
        guard shouldIgnore else { return self.trimmingCharacters(in: .whitespaces) }
        
        let lower = self.lowercased().trimmingCharacters(in: .whitespaces)
        // Standard English, Spanish, and Portuguese leading articles
        let articles = ["the ", "a ", "an ", "el ", "la ", "los ", "las ", "un ", "una ", "unos ", "unas ", "o ", "a ", "os ", "as ", "um ", "uma "]
        
        for article in articles {
            if lower.hasPrefix(article) {
                let index = self.index(self.startIndex, offsetBy: article.count)
                return String(self[index...]).trimmingCharacters(in: .whitespaces)
            }
        }
        return self.trimmingCharacters(in: .whitespaces)
    }
}
