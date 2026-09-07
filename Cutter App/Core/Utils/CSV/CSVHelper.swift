//
//  CSVHelper.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import Foundation

class CSVHelper {
    
    /// Parse CSV data from bundled version
    static func getCSVData() -> [CutterData] {
        guard let path = Bundle.main.path(forResource: "cutter_normal", ofType: "csv") else {
            print("No file found in bundle for version: cutter_normal")
            return []
        }
        let url = URL(fileURLWithPath: path)
        return getCSVData(from: url, hasHeaders: true)
    }
    
    /// Parse CSV data directly from a file URL (user-uploaded)
    static func getCSVData(from url: URL, hasHeaders: Bool = false) -> [CutterData] {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return parse(csvString: content, hasHeaders: hasHeaders)
        } catch {
            print("Error reading CSV file at \(url.path): \(error.localizedDescription)")
            return []
        }
    }
    
    /// Internal helper to parse raw CSV string into CutterData models
    private static func parse(csvString: String, hasHeaders: Bool) -> [CutterData] {
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
    private static func parseCSVRow(_ line: String) -> [String] {
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
    
    /// Parse ``CutterData`` array to CSV
    static func exportToCSV(with capturedText: [CutterData], addExtras: Bool = false) -> URL? {
        guard !capturedText.isEmpty else { return nil }
        
        var csvString = "Author,Name,Code,Number\(addExtras ? ",ISBN,Book Name,DDC" : "")\n"
        
        for item in capturedText {
            let cleanName = item.name.replacingOccurrences(of: "\"", with: "\"\"")
            let cleanBookName = item.bookName.replacingOccurrences(of: "\"", with: "\"\"")
            
            let extras = addExtras ? ",\"\(item.isbn)\",\"\(cleanBookName)\",\"\(item.ddcSelected)\"" : ""
            let row = "\"\(item.searchValue)\",\"\(cleanName)\",\"\(item.code)\",\"\(item.number)\"\(extras)\n"
            csvString.append(row)
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        let dateString = dateFormatter.string(from: Date())
        
        let fileName = "CutterApp_\(dateString).csv"
        let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try csvString.write(to: tempFileURL, atomically: true, encoding: .utf8)
            return tempFileURL
        } catch {
            print("Failed to save temporary CSV file: \(error.localizedDescription)")
            return nil
        }
    }
}
