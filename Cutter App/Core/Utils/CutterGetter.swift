//
//  CutterGetter.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/5/24.
//

import Foundation

final class CutterGetter {
    // Singleton
    static let shared  = CutterGetter()
    
    private var currentVersion = CsvVersion.normal //Default
    private var cutterData = [CutterData]()
    
    private init(){
        self.getCutterList()
    }
    
    func changeVersion(newVersion: CsvVersion){
        self.currentVersion = newVersion
        self.getCutterList()
    }
    
    func getCutterList(){
        self.cutterData = CSVParser().getCSVData(self.currentVersion)
    }
    
    func search(name:String, lastName:String, _data: [CutterData] = [CutterData]()) -> CutterData? {
        // We receive the data as a param so we can make Unit Testing easier
        var data = _data
        if(data.count == 0){
            data = self.cutterData
        }

        let query = CutterHelper.getQueryFromName(name: name, lastName: lastName)

        // Binary search
        var low = 0
        var high = data.count - 1
        var bestMatchIndex = 0

        while(low <= high){
            let mid = (low + high) / 2
            let candidateName = CutterHelper.removeAccents(query: data[mid].name)
            let cmp = query.compare(candidateName)

            if cmp == .orderedSame {
                return data[mid]
            } else if cmp == .orderedAscending {
                high = mid - 1
            } else {
               // The searched term is after candidateName,
               // we save this position as a valid predecessor candidate
                bestMatchIndex = mid
                low = mid + 1
            }
        }

        return data[bestMatchIndex]
    }
}
