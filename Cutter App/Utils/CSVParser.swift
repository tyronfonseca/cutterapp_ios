//
//  CSVReader.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import Foundation

class CSVParser {
    func getCSVData(_ csvVersion: CsvVersion)-> [CutterData]{
        
        var dataResult = [CutterData]()
        
        guard let path = Bundle.main.path(forResource: csvVersion.rawValue, ofType: "csv") else {
            print("No file found")
            return dataResult
        }
        
        do {
            let result = try String(contentsOfFile: path, encoding: .utf8).components(separatedBy: "\n")
            for row in result {
                let data = row.components(separatedBy: ";")
                dataResult.append(CutterData(name: data[0], value: data[1]))
            }
        }catch{
            print("Error parsing file")
        }
        
        return dataResult
    }
}
