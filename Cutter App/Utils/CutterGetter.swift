//
//  CutterGetter.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 7/5/24.
//

import Foundation

final class CutterGetter {
    static let shared  = CutterGetter()
    
    private var currentVersion = CsvVersion.normal //Default
    private var cutterData = [CutterData]()
    
    private init(){
        self.getData()
    }
    
    func changeVersion(newVersion: CsvVersion){
        self.currentVersion = newVersion
        self.getData()
    }
    
    func getData(){
        self.cutterData = CSVParser().getCSVData(self.currentVersion)
    }
    
    func search(name:String, lastName:String, _data: [CutterData] = [CutterData]()) -> CutterData? {
        // We receive the data as a param so we can make Unit Testing easier
        var data = _data
        if(data.count == 0){
            data = self.cutterData
        }
        
        var result: CutterData?
        let fullName = (lastName + ", " + name).uppercased()
        var searchValue = CutterHelper.convertStrToIntArr(str: fullName)
        
        let oldResult = [Int]()
        var index = 0
        var keepSearching = true
        while(keepSearching && index < data.count - 1){
            
            if(fullName.compareToInsen(rightStr: data[index].name)){
                result = data[index]
                keepSearching = false
            }else{
                var row = CutterHelper.convertStrToIntArr(str: data[index].name.uppercased())
                var secondRow = CutterHelper.convertStrToIntArr(str: data[index + 1].name.uppercased())
                
                // Fix values if the version is UCR
                if(currentVersion == CsvVersion.ucr)
                {
                    row = CutterHelper.ucrFix(list: row)
                    secondRow = CutterHelper.ucrFix(list: secondRow)
                    searchValue = CutterHelper.ucrFix(list: searchValue)
                }
                
                // use to determinate the lexicographic order
                let prevRow = CutterHelper.compareIntArrTo(leftArr: searchValue, rightArr: row)
                let nextRow = CutterHelper.compareIntArrTo(leftArr: searchValue, rightArr: secondRow)
                let pInitial = searchValue.last! - row.last!
                let sInitial = searchValue.last! - secondRow.last!
                
                // lexicographic order
                if(prevRow >= 0 && nextRow < 0){
                    let oldCompared = CutterHelper.compareIntArrTo(leftArr: oldResult, rightArr: row)
                    if(pInitial >= 0 && sInitial < 0){
                        result = data[index]
                    }else if (oldCompared < 0){
                        result = data[index]
                    }
                // The value is before preRow so we stop searching
                // and return the result
                }else if (prevRow < 0){
                    keepSearching = false
                }
                index += 1
            }
        }
        // Handle special case where the result was never found
        // Get last value
        if (result == nil){
            result = data[index]
        }

        return result
    }
}
