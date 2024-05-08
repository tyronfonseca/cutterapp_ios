//
//  CutterHelper.swift
//  Cutter App
//
//  Created by Tyron Fonseca on 6/5/24.
//

import Foundation

final class CutterHelper{
    
    static private let spaDict = ["Á": "A","É":"E","Í":"I","Ó":"O","Ú":"U","Ü":"U"]
    
    static private let oldAlph = ["A":1,"B":2,"C":3, "CH":4, "D":5,"E":6,"F":7,"G":8,"H":9,"I":10,"J":11,
                           "K":12,"L":13, "LL":14,"M":15,"N":16,"Ñ":17,"O":18,"P":19,"Q":20,"R":21,"S":22,"T":23,
                           "U":24,"V":25,"W":26,"X":27,"Y":28,"Z":29,"@":30,",":0, " ":0, "-":0]
    
    static func convertStrToIntArr(str: String) -> [Int] {
        var result = [Int]()
        var tmp:String?
        var intValue:Int?
        
        for (_, char) in str.enumerated() {
            var letter = String(char)
            tmp = spaDict[letter]
            
            if(tmp != nil){
                letter = tmp!
            }
            
            intValue = oldAlph[letter]
            if (intValue != nil){
                result.append(intValue!)
            }
        }
        
        return result
    }
    
    static func compareIntArrTo(leftArr: [Int], rightArr: [Int]) -> Int{
        let leftLen = leftArr.count
        let rightLen = rightArr.count
        let limit = min(leftLen, rightLen)
        var index = 0
        
        while(index < limit){
            let c1 = leftArr[index]
            let c2 = rightArr[index]
            
            if(c1 != c2){
                return c1 - c2
            }
            index += 1
        }
        
        return leftLen - rightLen
    }
    
    static func getFirstLetter(word:String, currVersion: CsvVersion) -> String {
        let firstLetter = word[0]
        let secondLetter = word[1]
        var letter = String(firstLetter)
        
        if(currVersion == .ucr){
            if(firstLetter == "C" && secondLetter == "h"){
                letter = "Ch"
            }else if (firstLetter == "L" && secondLetter == "l"){
                letter = "Ll"
            }
        }
        
        return letter
    }
    
    
    static func ucrFix(list: [Int]) -> [Int] {
        var toAdd = 0
        var listResult = [Int]()
        var index = 1
        
        while (index <= list.count - 1) {
            let firstChar = list[index - 1]
            let secondChar = list[index]
            toAdd = firstChar
            
            if (firstChar == oldAlph["C"] && secondChar == oldAlph["H"]){
                toAdd = oldAlph["CH"]!
                index += 1
            } else if (firstChar == oldAlph["L"] && secondChar == oldAlph["L"]){
                toAdd = oldAlph["LL"]!
                index += 1
            }
            index += 1
            listResult.append(toAdd)
            
            if(index == list.count){
                listResult.append(secondChar)
            }
        }
        
        return listResult
    }
}
