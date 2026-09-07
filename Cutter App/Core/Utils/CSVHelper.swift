//
//  CSVReader.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import Foundation

class CSVParser {
    
    /// Parse CSV data from bundled version
    func getCSVData() -> [CutterData] {
        guard let path = Bundle.main.path(forResource: "cutter_normal", ofType: "csv") else {
            print("No file found in bundle for version: cutter_normal")
            return []
        }
        let url = URL(fileURLWithPath: path)
        return getCSVData(from: url, hasHeaders: true)
    }
    
    /// Parse CSV data directly from a file URL (user-uploaded)
    func getCSVData(from url: URL, hasHeaders: Bool = false) -> [CutterData] {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return parse(csvString: content, hasHeaders: hasHeaders)
        } catch {
            print("Error reading CSV file at \(url.path): \(error.localizedDescription)")
            return []
        }
    }
    
    /// Internal helper to parse raw CSV string into CutterData models
    private func parse(csvString: String, hasHeaders: Bool) -> [CutterData] {
        let rows = csvString.components(separatedBy: .newlines)
        let contentRows = hasHeaders ? Array(rows.dropFirst()) : rows
        
        return contentRows.compactMap { row in
            let fields = parseCSVRow(row)
            guard fields.count >= 2 else { return nil }
            
            let name = fields[0]
            let code = fields[1]
            
            guard !name.isEmpty || !code.isEmpty else { return nil }
            return CutterData(name: name, code: code)
        }
    }

    /// Parses a single CSV line into trimmed field strings, preserving text inside quotes.
    private func parseCSVRow(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        for char in line {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == "," && !insideQuotes {
                fields.append(currentField.trimmingCharacters(in: .whitespaces))
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        fields.append(currentField.trimmingCharacters(in: .whitespaces))
        return fields
    }
}
