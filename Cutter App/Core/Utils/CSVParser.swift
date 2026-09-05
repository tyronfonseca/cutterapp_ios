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
        return getCSVData(from: url)
    }
    
    /// Parse CSV data directly from a file URL (bundled or user-uploaded)
    func getCSVData(from url: URL) -> [CutterData] {
        do {
            let content = try String(contentsOf: url, encoding: .utf8)
            return parse(csvString: content)
        } catch {
            print("Error reading CSV file at \(url.path): \(error.localizedDescription)")
            return []
        }
    }
    
    /// Internal helper to parse raw CSV string into CutterData models
    private func parse(csvString: String) -> [CutterData] {
        var dataResult = [CutterData]()
        let rows = csvString.components(separatedBy: .newlines)
        
        for row in rows {
            let trimmedRow = row.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmedRow.isEmpty else { continue }
            
            let data = trimmedRow.components(separatedBy: ";")
            
            // Validate that row contains at least name and code columns
            if data.count >= 2 {
                let name = data[0].trimmingCharacters(in: .whitespaces)
                let code = data[1].trimmingCharacters(in: .whitespaces)
                
                dataResult.append(CutterData(name: name, code: code))
            }
        }
        
        return dataResult
    }
}
